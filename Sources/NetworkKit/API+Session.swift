import Foundation

@available(iOS 17.0, *)
extension API {
    public protocol Session: Sendable {
        func data(for request: URLRequest) async throws -> (Data, URLResponse)
        func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)
    }
}

extension URLSession: API.Session {}
