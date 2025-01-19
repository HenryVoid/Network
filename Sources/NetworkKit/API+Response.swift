import Foundation

extension API {
    public struct Response: Sendable {
        public let data: Data
        public let response: URLResponse
        
        public init(data: Data, response: URLResponse) {
            self.data = data
            self.response = response
        }
    }
}

extension URLResponse {
    public func statusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        } else {
            return nil
        }
    }
}
