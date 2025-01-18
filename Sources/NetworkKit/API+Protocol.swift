import Foundation

#if !os(macOS)
extension API {
    public protocol `Protocol` {
        @MainActor func request<T: Decodable>(_ endpoint: API.Endpoint, decode: T.Type) async throws(API.Error) -> T
        @MainActor func upload<T: Decodable>(_ endpoint: API.Endpoint, decode: T.Type) async throws(API.Error) -> T
    }
}
#endif
