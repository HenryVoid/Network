import Foundation
@testable import NetworkKit

@available(iOS 17.0, *)
enum Mock {
    struct Session: API.Session, @unchecked Sendable {
        var dataHandler: (URLRequest) async throws -> (Data, URLResponse)
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try await dataHandler(request)
        }
    }
    
    struct Response: Decodable {
        let response: String
    }
    
    struct Endpoint: API.Endpoint {
        var baseURL: API.URLConvertible = "https://www.naver.com"
        var path: String? = nil
        var method: API.HTTPMethod = .get
        var parameters: API.Parameters? = nil
        var headers: API.HttpHeaders? = nil
        var encoder: API.ParameterEncodable = API.URLParameterEncoder()
    }
    
    struct Interceptor: API.Interceptor, @unchecked Sendable {
        var adaptHandler: (URLRequest) async throws(API.Error) -> URLRequest = { urlRequest in
            return urlRequest
        }
        var retryHandler: (URLRequest, URLResponse?, Data?, any Error) async -> (URLRequest, API.RetryResult) = { urlRequest, _, _, error in
            return (urlRequest, .doNotRetry(with: error))
        }
        
        func adapt(urlRequest: URLRequest) async throws(API.Error) -> URLRequest {
            return try await adaptHandler(urlRequest)
        }
        
        func retry(
            urlRequest: URLRequest,
            response: URLResponse?,
            data: Data?,
            with error: any Error
        ) async -> (URLRequest, API.RetryResult) {
            return await retryHandler(urlRequest, response, data, error)
        }
    }
}

extension Data {
    var asString: String {
        String(decoding: self, as: UTF8.self)
    }

    func asJSONObject() throws -> Any {
        try JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
}
