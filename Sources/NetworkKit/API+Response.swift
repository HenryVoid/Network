import Foundation

public struct Response: Sendable {
    public let data: Data
    public let response: URLResponse
    
    public init(data: Data, response: URLResponse) {
        self.data = data
        self.response = response
    }
}
