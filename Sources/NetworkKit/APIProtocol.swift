//
//  APIProtocol.swift
//
//
//  Created by 송형욱 on 4/5/24.
//

import Foundation

protocol APIProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, decode: T.Type) async throws -> T
}
