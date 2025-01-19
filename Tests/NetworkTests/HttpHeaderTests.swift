import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct HttpHeaderTests {

    @Test
    func dictionary변환() async throws {
        let headers: API.HttpHeaders = [.init(key: "key", value: "value")]
        let headersDic: [String: String] = ["key": "value"]
        
        #expect(headers.dictionary == headersDic)
    }

    @Test
    func dictionaryString변환() async throws {
        let header: API.HttpHeader = .init(key: "key", value: "value")
        let headerStr: String = "key: value"
        
        #expect(header.toDictionaryString == headerStr)
    }
    
    @Test
    func headers_추가() async throws {
        let headers: API.HttpHeaders = [
            .init(key: "key1", value: "value1"),
            .init(key: "key2", value: "value2")
        ]
        
        let url: URL = .init(string: "https://www.naver.com")!
        var urlRequest: URLRequest = .init(url: url)
        
        let headersDic: [String: String] = [
            "key1": "value1",
            "key2": "value2",
          ]
        
        urlRequest.setHeaders(headers)
        
        #expect(urlRequest.allHTTPHeaderFields == headersDic)
    }
}
#endif
