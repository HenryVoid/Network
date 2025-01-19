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
                let response: API.Response = try await fetch(with: urlRequest)
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
        
//        public func upload<T>(_ endpoint: any Endpoint, decode: T.Type) async throws -> T where T : Decodable {
//
//        }
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
}
