import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct EndpointTests {
    
    @Test
    func jsonParameter_성공() async throws {
        let baseURL = "https://www.naver.com"
        let path = "path"
        let method: API.HTTPMethod = .get
        let parameters: API.Parameters = ["name": "Henry"]
        let headers: API.HttpHeaders = [.init(key: "key", value: "value")]
        let encoder: API.ParameterEncodable = .json
        
        let endpoint: API.Endpoint = Mock.Endpoint(
            baseURL: baseURL,
            path: path,
            method: method,
            parameters: parameters,
            headers: headers,
            encoder: encoder
        )
        
        let result = try endpoint.asURLRequest()
        
        #expect(result.url?.absoluteString == "\(baseURL)/path")
        #expect(result.httpMethod == method.rawValue)
        #expect(result.url?.query() == nil)
        #expect(result.allHTTPHeaderFields == headers.dictionary)
        #expect(try result.httpBody?.asJSONObject() == parameters.asNSObejct)
    }
    
    @Test
    func urlParameter_성공() async throws {
        let baseURL = "https://www.naver.com"
        let path = "path"
        let method: API.HTTPMethod = .get
        let parameters: API.Parameters = ["name": "Henry"]
        let headers: API.HttpHeaders = [.init(key: "key", value: "value")]
        let encoder: API.ParameterEncodable = .url
        
        let endpoint: API.Endpoint = Mock.Endpoint(
            baseURL: baseURL,
            path: path,
            method: method,
            parameters: parameters,
            headers: headers,
            encoder: encoder
        )
        
        let result = try endpoint.asURLRequest()
        
        #expect(result.url?.absoluteString == "\(baseURL)/\(path)?\(parameters.asString)")
        #expect(result.httpMethod == method.rawValue)
        #expect(result.url?.query() == parameters.asString)
        #expect(result.allHTTPHeaderFields == headers.dictionary)
        #expect(result.httpBody == nil)
    }

}
#endif
