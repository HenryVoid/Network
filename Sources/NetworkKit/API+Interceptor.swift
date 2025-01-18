import Foundation

extension API {
    protocol Interceptor {
        func adapt(urlRequest: URLRequest) async throws(API.Error) -> URLRequest
        func retry(
            urlRequest: URLRequest,
            response: URLResponse?,
            data: Data?,
            with error: any Error
        ) async -> (URLRequest, RetryResult)
    }
}
