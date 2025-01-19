import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct ClientTests {
    
    @Test
    func URL_유효성검사_실패() async throws {
        let url: URL = .init(string: "https://www.test.com")!
        let data: Data = "test".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let session: API.Session = Mock.Session { _ in
            return (data, response)
        }
        let client: API.Client = .init(
            session: session,
            monitor: nil,
            interceptors: []
        )
        let endpoint = Mock.Endpoint(baseURL: "")
        
        await #expect(throws: API.Error.self) { // Configuration.invalidURL
            _ = try await client.request(endpoint, decode: Mock.Response.self)
        }
    }
    
    @Test
    func Data_가져오기_실패() async throws {
        let session: API.Session = Mock.Session { _ in
            throw NSError(domain: "1", code: 1)
        }
        let client: API.Client = .init(
            session: session,
            monitor: nil,
            interceptors: []
        )
        let endpoint = Mock.Endpoint()
        
        await #expect(throws: API.Error.self) { // Session.failedDataRequest
            _ = try await client.request(endpoint, decode: Mock.Response.self)
        }
    }
    
    @Test
    func decode_실패() async throws {
        let url: URL = .init(string: "https://www.test.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let session: API.Session = Mock.Session { _ in
            let data = "invalid format".data(using: .utf8)!
            return (data, response)
        }
        let client: API.Client = .init(
            session: session,
            monitor: nil,
            interceptors: []
        )
        let endpoint = Mock.Endpoint()
        
        await #expect(throws: API.Error.self) { // Decoding.failedToDecode
            _ = try await client.request(endpoint, decode: Mock.Response.self)
        }
    }
    
    @Test
    func statusCode_유효성검사_실패() async throws {
        let url: URL = .init(string: "https://www.test.com")!
        let data: Data = "test".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let session: API.Session = Mock.Session { _ in
            (data, response)
        }
        let client: API.Client = .init(
            session: session,
            monitor: nil,
            interceptors: []
        )
        let endpoint = Mock.Endpoint()
        
        await #expect(throws: API.Error.self) { // Response.invalidStatusCode
            _ = try await client.request(endpoint, decode: Mock.Response.self)
        }
    }
    
    @Test
    func response_실패() async throws {
        let data: Data = "test".data(using: .utf8)!
        let response = URLResponse()
        let session: API.Session = Mock.Session { _ in
            (data, response)
        }
        let client: API.Client = .init(
            session: session,
            monitor: nil,
            interceptors: []
        )
        let endpoint = Mock.Endpoint()
        
        await #expect(throws: API.Error.self) { // Response.invalidResponse
            _ = try await client.request(endpoint, decode: Mock.Response.self)
        }
    }
}
#endif
