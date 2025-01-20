import Testing
import Foundation

@testable import NetworkKit

#if !os(macOS)
@MainActor
struct MonitorTests {

    @Test
    func 네트워크연결_성공() async throws {
        let monitor: API.Monitorable = API.Monitor.shared
        monitor.connect()
        let isConnected = await monitor.isConnected()
        monitor.cancel()
        
        #expect(isConnected == true)
    }

}
#endif
