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
    var baseURL: String { "" }
    
    private var defaultHeaders: HTTPHeaders {
        var headers: HTTPHeaders = [
            .accept("application/json"),
            .contentType("application/json")
        ]
        
        if let token = token {
            headers.add(.authorization(bearerToken: token))
        }
        
        return headers
    }
    
    public func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL)?.appendingPathComponent(path) else {
            throw APIError(
                errorCode: "ERROR",
                message: "Invalid baseURL or path"
            )
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // Query
        if let queryItems = queryItems {
            components?.queryItems = queryItems.map { URLQueryItem(name: $0.name, value: $0.value) }
        }
        
        guard let finalURL = components?.url else {
            throw APIError(
                errorCode: "ERROR",
                message: "Invalid URL Component"
            )
        }
        
        var request = URLRequest(url: finalURL)
        // Method
        request.method = method
        
        // Header
        var finalHeader = defaultHeaders
        if let customHeaders = headers {
            customHeaders.forEach { finalHeader.update($0) }
        }
        
        request.headers = finalHeader
        
        // Body
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        return request
    }
}
