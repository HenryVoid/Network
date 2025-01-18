import Foundation

#if !os(macOS)
extension API {
    protocol Session {
        func data(for request: URLRequest) async throws -> (Data, URLResponse)
    }
}

extension URLSession: API.Session {}
#endif
