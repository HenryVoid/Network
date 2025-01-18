import Foundation
import Network

#if !os(macOS)
extension API {
    protocol Monitorable {
        func connect()
        func cancel()
    }
    
    struct Monitor {
        private let queue: DispatchQueue = .init(label: "API.Monitor")
        private let monitor: NWPathMonitor = .init()
        public private(set) var isConnected: Bool = false
        
        init() { start() }
        
        deinit { cancel() }
    }
}

extension API.Monitor: API.Monitorable {
    private func start() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            // 네트워크 사용 가능 여부
            self.isConnected = path.status == .satisfied
        }
    }
    
    private func cancel() {
        monitor.cancel()
    }
}
#endif
