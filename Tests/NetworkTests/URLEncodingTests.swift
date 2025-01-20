//
//  Test.swift
//  NetworkKit
//
//  Created by 송형욱 on 1/20/25.
//

import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct Test {

    @Test
    func encode_성공() async throws {
        let encoder: any API.ParameterEncodable = API.URLParameterEncoder()
        let urlRequest: URLRequest = .init(url: .init(string: "https://www.naver.com")!)
        let parameters: API.Parameters = [
            "name": "henry",
            "age": "123"
        ]
        
        let result = try encoder.encode(request: urlRequest, with: parameters)
        
        guard let url = result.url,
              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            Issue.record()
            return
        }
        for queryItem in queryItems {
            #expect(parameters.contains(where: { $0.key == queryItem.name }))
            #expect(parameters.contains(where: { $0.value as? String == queryItem.value }))
        }
    }

}
#endif
