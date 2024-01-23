
import Foundation

protocol NetworkRequestable {
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkRequestable {}

protocol NetworkProviderType: AnyObject {
    @discardableResult
    func request<T: Decodable>(endpoint: EndpointType, type: T.Type) async throws -> T
}

final class NetworkProvider: NetworkProviderType {
    
    // MARK: Properties
    private let session: NetworkRequestable
    
    // MARK: Initializer
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: Methods
    @discardableResult
    func request<T: Decodable>(endpoint: EndpointType, type: T.Type) async throws -> T {
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.failConnection
        }
        
        let request: URLRequest = try endpoint.makeURLRequest()
        let (data, response) = try await session.data(for: request)
        try filterNetworkingError(data: data, response: response)
        
        let result = try filterDecodingError(data: data, type: T.self)
        
        return result
    }
}

// MARK: - Private
private extension NetworkProvider {
    func filterNetworkingError(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.responseError
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidStatusCode(code: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw NetworkError.emptyData
        }
    }
    
    func filterDecodingError<T: Decodable>(data: Data, type: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, _) {
            throw NetworkError.decodingKeyError(key: key.stringValue)
        } catch DecodingError.typeMismatch(_, let context) {
            throw NetworkError.decodingTypeError(keys: context.codingPath)
        } catch DecodingError.valueNotFound(_, let context) {
            throw NetworkError.decodingValueError(keys: context.codingPath)
        } catch {
            throw NetworkError.unknownError(message: "알 수 없는 오류가 발생했어요")
        }
    }
}
