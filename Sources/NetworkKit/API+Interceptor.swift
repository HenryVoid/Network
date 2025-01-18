import Foundation

extension API {
    public enum RetryResult {
      case retry
      case doNotRetry(with: Error)
    }
    
    protocol Interceptor {
        func adapt(urlRequest: URLRequest) async throws(API.Error) -> URLRequest
        func retry(
            urlRequest: URLRequest,
            response: URLResponse?,
            data: Data?,
            with error: any Swift.Error
        ) async -> (URLRequest, API.RetryResult)
    }
}
