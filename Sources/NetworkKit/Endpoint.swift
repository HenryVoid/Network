//
//  Endpoint.swift
//
//
//  Created by 송형욱 on 4/5/24.
//

import Foundation
import Alamofire

protocol Endpoint: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: HTTPHeaders? { get }
    var body: Parameters? { get }
    var token: String? { get }
    var multipart: MultipartFormData? { get }
}

extension Endpoint {
    // TODO: Common Endpoint property
}
