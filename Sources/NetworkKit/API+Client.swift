import Foundation

#if !os(macOS)
extension API {
    public final class Client: API.Protocol {
        private let session: any API.Session
        private let monitor: (any API.Monitorable)?
        private let logger: (any API.Loggable)?
        private let interceptors: [API.Interceptor]
        
        public init(
            session: any API.Session,
            monitor: (any API.Monitorable)? = .shared,
            logger: (any API.Loggable)? = .shared,
            interceptors: [API.Interceptor]
        ) {
            self.session = session
            self.monitor = monitor
            self.logger = logger
            self.interceptors = interceptors
        }
        
        @MainActor
        public func request<T: Decodable>(_ endpoint: API.Endpoint, decode: T.Type) async throws -> T {
            do {
                let urlRequest = URLRequest = try await
                logger?.request(urlRequest)
                return try self.manageResponse(data: result.data, response: result.response)
            } catch {
                
            }
        }
        
        public func upload<T>(_ endpoint: any Endpoint, decode: T.Type) async throws -> T where T : Decodable {
            do {
                let result = try await self.session.upload(multipartFormData: { multipartFormData in
                    if let data = endpoint.body?["data"] as? Data {
                        multipartFormData.append(data, withName: "image")
                    }
                }, with: endpoint.asURLRequest()).serializingData(automaticallyCancelling: true).response
                return try self.manageResponse(data: result.data, response: result.response)
            } catch let error as APIError {
                throw error
            } catch {
                throw APIError(
                    errorCode: "ERROR",
                    message: "Unknown API error \(error.localizedDescription)"
                )
            }
        }
    }
}

extension API.Client {
    // MARK: Private
    
    private func adaptInterceptor(_ endpoint: API.Endpoint) async throws(API.Error) -> URLRequest {
        var urlRequest: URLRequest = try endpoint.asURLRequest()
        interceptors.forEach {
            urlRequest = try await $0.adapt(urlRequest: urlRequest)
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
    
    private func validate(_ response: Response) throws(API.Error.Response) {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        guard (200..<300) ~= httpResponse.statusCode else {
            throw .invalidStatusCode(httpResponse.statusCode)
        }
    }
    
    private func decode<Model: Decodable>(
        _ response: Response,
        with decoder: JSONDecoder
    ) throws(API.Error.Decoding) -> Model {
        do {
            let model = try decoder.decode(Model.self, from: response.data)
            return model
        }
        catch let error as Swift.DecodingError {
            throw .failedToDecode(error)
        }
        catch {
            throw .unknown
        }
    }
}
#endif
