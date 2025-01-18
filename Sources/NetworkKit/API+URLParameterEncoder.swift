import Foundation

extension API {
    public struct URLParameterEncoder: API.ParameterEncodable {
        public init() { }
        
        public func encode(
            request: URLRequest,
            with parameters: API.Parameters?
        ) throws(API.Error.Encoding) -> URLRequest {
            
            guard let parameters else { return request }
            var request = request
            
            guard let url = request.url else {
                throw API.Error.Encoding.missingURL
            }
            
            guard var urlComponents = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            ) else {
                return request
            }
            
            let queryItems = parameters
                .map { key, value in
                    let stringValue: String = "\(value)"
                    let percentEncodedKey: String = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                    let percentEncodedValue: String = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? stringValue
                    return (percentEncodedKey, percentEncodedValue)
                }
                .compactMap(URLQueryItem.init)
            
            if urlComponents.percentEncodedQueryItems == nil {
                urlComponents.percentEncodedQueryItems = queryItems
            } else {
                urlComponents.percentEncodedQueryItems?.append(contentsOf: queryItems)
            }
            
            request.url = urlComponents.url
            
            return request
        }
    }
}
