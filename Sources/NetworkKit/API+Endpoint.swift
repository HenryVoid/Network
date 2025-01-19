import Foundation

@available(iOS 17.0, *)
extension API {
    public protocol Endpoint: Sendable {
        var baseURL: any URLConvertible { get }
        var path: String? { get }
        var method: API.HTTPMethod { get }
        var headers: API.HttpHeaders? { get }
        var parameters: API.Parameters? { get }
        var encoder: any API.ParameterEncodable { get }
        func asURLRequest() throws(API.Error) -> URLRequest
    }
}

@available(iOS 17.0, *)
extension API.Endpoint {
    public func asURLRequest() throws(API.Error) -> URLRequest {
        do {
            let url = try baseURL.asURL()
            var request = URLRequest(url: url)
            
            if let path {
                request.url?.append(path: path)
            }
            
            if let headers {
                request.setHeaders(headers)
            }
            
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers?.dictionary
            
            return try encoder.encode(request: request, with: parameters)
        } catch let error as API.Error.Configuration {
            throw .configuration(error)
        } catch let error as API.Error.Encoding {
            throw .encoding(error)
        } catch {
            throw .unknown
        }
    }
}
