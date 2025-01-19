import Foundation
import Network

@available(iOS 17.0, *)
extension API {
    public protocol Monitorable: Sendable {
        func connect()
        func isConnected() async -> Bool
        func cancel()
    }
    
    public struct Monitor: API.Monitorable, Sendable {
        public static let shared: Monitor = .init()
        private let queue: DispatchQueue = .init(label: "API.Monitor")
        private let monitor: NWPathMonitor = .init()
    }
}

@available(iOS 17.0, *)
extension API.Monitor {
    public func connect() {
        monitor.start(queue: queue)
    }
    
    public func isConnected() async -> Bool {
        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                // 네트워크 사용 가능 여부
                continuation.resume(returning: path.status == .satisfied)
            }
        }
        
    }
    
    public func cancel() {
        monitor.cancel()
    }
}
