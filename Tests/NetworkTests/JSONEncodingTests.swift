import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct JSONEncodingTests {
    
    @Test
    func encode_성공() async throws {
        let encoder: any API.ParameterEncodable = API.JSONParameterEncoder()
        let urlRequest: URLRequest = .init(url: .init(string: "https://www.naver.com")!)
        let parameters: [String: Sendable & Any] = [
          "name": "henry",
          "array": ["a", 1, true] as [Sendable & Any],
          "object": [
            "a": 1,
            "b": [2, 2],
            "c": ["3", "3", "3"]
          ] as [String: Sendable & Any]
        ]
        
        let result = try encoder.encode(request: urlRequest, with: parameters)
        
        #expect(result.httpBody != nil)
        #expect(try result.httpBody?.asJSONObject() == parameters.asNSObejct)
    }

}
#endif
