import Foundation

@available(iOS 17.0, *)
extension API {
    public final class Client: Sendable {
        private let session: any API.Session
        private let monitor: (any API.Monitorable)?
        private let logger: (any API.Loggable)?
        private let interceptors: [API.Interceptor]
        
        public init(
            session: any API.Session,
            monitor: (any API.Monitorable)? = API.Monitor.shared,
            logger: (any API.Loggable)? = API.Logger.shared,
            interceptors: [API.Interceptor]
        ) {
            self.session = session
            self.monitor = monitor
            self.logger = logger
            self.interceptors = interceptors
            
            self.monitor?.connect()
        }
        
        deinit {
            self.monitor?.cancel()
        }
        
        @MainActor
        public func request<T: Decodable>(_ endpoint: API.Endpoint, decode: T.Type) async throws(API.Error) -> T {
            do {
                if let monitor,
                   await !monitor.isConnected() {
                    throw API.Error.connection(.failed)
                }
                let urlRequest: URLRequest = try await makeURLRequest(endpoint)
                logger?.request(urlRequest)
                let response: API.Response = try await fetchWithRetry(urlRequest: urlRequest)
                logger?.response(response: response)
                return try makeResult(response)
            } catch let error as API.Error {
                logger?.response(error: error)
                throw error
            } catch {
                logger?.response(error: error)
                throw .unknown
            }
        }
        
        @MainActor
        public func upload<T: Decodable>(_ endpoint: API.Endpoint, decode: T.Type) async throws(API.Error) -> T {
            do {
                monitor?.connect()
                if let monitor,
                   await !monitor.isConnected() {
                    throw API.Error.connection(.failed)
                }
                
                var urlRequest: URLRequest = try await makeURLRequest(endpoint)
                
                guard let uploadData = endpoint.uploadData else {
                    throw API.Error.encoding(.missingUploadData)
                }
                
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                let bodyData = try makeMultipartFormData(data: uploadData, boundary: boundary)
                
                logger?.request(urlRequest)
                let response = try await uploadWithRetry(urlRequest: urlRequest, bodyData: bodyData)
                logger?.response(response: response)
                monitor?.cancel()
                return try makeResult(response)
            } catch let error as API.Error {
                logger?.response(error: error)
                monitor?.cancel()
                throw error
            } catch {
                logger?.response(error: error)
                monitor?.cancel()
                throw .unknown
            }
        }
    }
}

@available(iOS 17.0, *)
extension API.Client {
    // MARK: Private
    
    private func makeURLRequest(_ endpoint: API.Endpoint) async throws(API.Error) -> URLRequest {
        var urlRequest: URLRequest = try endpoint.asURLRequest()
        for interceptor in interceptors {
          urlRequest = try await interceptor.adapt(urlRequest: urlRequest)
        }
        return urlRequest
    }
    
    private func fetch(with urlRequest: URLRequest) async throws(API.Error.Session) -> API.Response {
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            let response: API.Response = API.Response(data: data, response: urlResponse)
            return response
        }
        catch {
            throw .failedDataRequest
        }
    }
    
    private func fetchUpload(with urlRequest: URLRequest, bodyData: Data) async throws(API.Error.Session) -> API.Response {
        do {
            let (data, urlResponse) = try await session.upload(for: urlRequest, from: bodyData)
            let response: API.Response = API.Response(data: data, response: urlResponse)
            return response
        }
        catch {
            throw .failedDataRequest
        }
    }
    
    private func makeMultipartFormData(data: API.UploadData, boundary: String) throws -> Data {
        var body = Data()
        
        // 경계선 시작
        body.append("--\(boundary)\r\n")
        
        // Content-Disposition 헤더
        let disposition = "Content-Disposition: form-data; name=\"\(data.name)\"; filename=\"\(data.filename)\"\r\n"
        guard let dispositionData = disposition.data(using: .utf8) else {
            throw API.Error.encoding(.invalidEncoding)
        }
        body.append(dispositionData)
        
        // Content-Type 헤더
        let contentType = "Content-Type: \(data.mimeType.value)\r\n\r\n"
        guard let contentTypeData = contentType.data(using: .utf8) else {
            throw API.Error.encoding(.invalidEncoding)
        }
        body.append(contentTypeData)
        
        // 파일 데이터
        body.append(data.data)
        body.append("\r\n".data(using: .utf8)!)
        
        // 경계선 종료
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }

    private func makeResult<T: Decodable>(_ response: API.Response) throws(API.Error) -> T {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            throw .response(.invalidResponse)
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try decode(response.data, type: T.self)
        default:
            guard let serverError = try? decode(response.data, type: API.Error.ServerError.self) else {
                throw .response(.invalidStatusCode(httpResponse.statusCode))
            }
            throw .response(.server(serverError))
        }
    }
    
    private func decode<T: Decodable>(_ data: Data, type decode: T.Type) throws(API.Error) -> T {
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        }
        catch let error as Swift.DecodingError {
            throw .decoding(.failedToDecode(error))
        }
        catch {
            throw .unknown
        }
    }

    // 재시도 로직이 포함된 업로드 함수
    private func uploadWithRetry(
        urlRequest: URLRequest,
        bodyData: Data,
        retryCount: Int = 3,
        currentAttempt: Int = 0
    ) async throws -> API.Response {
        guard currentAttempt < retryCount else {
            throw API.Error.session(.failedDataRequest)
        }
        
        do {
            return try await fetchUpload(with: urlRequest, bodyData: bodyData)
        } catch {
            // 인터셉터를 통한 재시도 처리
            for interceptor in interceptors {
                let (newRequest, retryResult) = await interceptor.retry(
                    urlRequest: urlRequest,
                    response: nil,
                    data: nil,
                    with: error
                )
                
                switch retryResult {
                case .retry:
                    // 지수 백오프를 사용한 대기 시간
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(currentAttempt)) * 1_000_000_000))
                    // 재귀적으로 다시 시도
                    return try await uploadWithRetry(
                        urlRequest: newRequest,
                        bodyData: bodyData,
                        retryCount: retryCount,
                        currentAttempt: currentAttempt + 1
                    )
                case .doNotRetry(let error):
                    throw error
                }
            }
            
            throw error
        }
    }

    private func fetchWithRetry(
        urlRequest: URLRequest,
        retryCount: Int = 3
    ) async throws -> API.Response {
        var currentRetry = 0
        var lastError: Error?
        
        while currentRetry < retryCount {
            do {
                return try await fetch(with: urlRequest)
            } catch {
                lastError = error
                currentRetry += 1
                
                // 인터셉터를 통한 재시도 처리
                for interceptor in interceptors {
                    let (newRequest, retryResult) = await interceptor.retry(
                        urlRequest: urlRequest,
                        response: nil,
                        data: nil,
                        with: error
                    )
                    
                    switch retryResult {
                    case .retry:
                        // 잠시 대기 후 재시도
                        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(currentRetry)) * 1_000_000_000))
                        continue
                    case .doNotRetry(let error):
                        throw error
                    }
                }
            }
        }
        
        throw API.Error.session(.failedDataRequest)
    }
}
