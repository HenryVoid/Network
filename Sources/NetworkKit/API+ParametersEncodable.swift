import Foundation

extension API {
    public protocol ParameterEncodable: Sendable {
        func encode(
            request: URLRequest,
            with parameters: API.Parameters?
        ) throws(API.Error.Encoding) -> URLRequest
    }
}

extension API.ParameterEncodable where Self == API.URLParameterEncoder {
    public static var url: API.URLParameterEncoder { return .init() }
}

extension API.ParameterEncodable where Self == API.JSONParameterEncoder {
    public static var json: API.JSONParameterEncoder { return .init() }
}

