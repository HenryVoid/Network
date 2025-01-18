import Foundation

extension API {
    public struct JSONParameterEncoder: API.ParameterEncodable {
        public init() { }
        
        public func encode(
            request: URLRequest,
            with parameters: API.Parameters?
        ) throws(API.Error.Encoding) -> URLRequest {
            guard let parameters else { return request }
            var request = request
            
            guard JSONSerialization.isValidJSONObject(parameters) else {
                throw API.Error.Encoding.invalidJSON
            }
            
            do {
                let data: Data = try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
                request.httpBody = data
            } catch {
                throw API.Error.Encoding.jsonEncodingFailed
            }
            return request
        }
    }
}

