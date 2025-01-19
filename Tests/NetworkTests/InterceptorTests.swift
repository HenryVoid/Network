import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct InterceptorTests {

    @Test
    func interceptor_adapt_성공() async throws {
        let interceptor: Mock.Interceptor = .init { urlRequest in
            var request = urlRequest
            request.setHeaders([
                .contentType(value: "application/json"),
                .authorization("auth"),
                .userAgent(value: "userAgent"),
                .init(key: "key", value: "value")
            ])
            return request
        }
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "auth",
            "User-Agent": "userAgent",
            "key": "value"
          ]
        let urlRequest: URLRequest = .init(url: .init(string: "https://www.naver.com")!)
        let adaptedURLRequest = try await interceptor.adapt(urlRequest: urlRequest)
        #expect(adaptedURLRequest.allHTTPHeaderFields == headers)
    }

}
#endif
