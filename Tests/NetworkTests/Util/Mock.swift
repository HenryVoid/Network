import Foundation
@testable import Network

#if !os(macOS)
struct MockNetworkSession: API.Session {
    var dataHandler: (URLRequest) async throws -> (Data, URLResponse)
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await dataHandler(request)
    }
}

struct MockResponse: Decodable {
    let response: String
}

struct MockEndpoint: URLRequestConfigurable {
    var url: URLConvertible = "https://www.naver.com"
    var path: String? = nil
    var method: HTTPMethod = .get
    var parameters: Parameters? = nil
    var headers: [Header]? = nil
    var encoder: ParameterEncodable = URLParameterEncoder()
}

struct MockInterceptor: Interceptor {
    var adaptHandler: (URLRequest) async throws(Errors) -> URLRequest = { urlRequest in
        return urlRequest
    }
    var retryHandler: (URLRequest, URLResponse?, Data?, any Error) async -> (URLRequest, RetryResult) = { urlRequest, _, _, error in
        return (urlRequest, .doNotRetry(with: error))
    }
    
    func adapt(urlRequest: URLRequest) async throws(Errors) -> URLRequest {
        return try await adaptHandler(urlRequest)
    }
    
    func retry(
        urlRequest: URLRequest,
        response: URLResponse?,
        data: Data?,
        with error: any Error
    ) async -> (URLRequest, RetryResult) {
        return await retryHandler(urlRequest, response, data, error)
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
#endif
