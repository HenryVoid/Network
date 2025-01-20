import Testing
import Foundation

@testable import NetworkKit

struct URLConvertibleTests {

    @Test
    func String을_URL로() async throws {
        let urlString = "https://www.example.com"
        
        let url = try urlString.asURL()
        #expect(url.absoluteString == urlString)
    }

    @Test
    func 잘못된_url주소입력() async throws {
        let urlString = ""
        
        #expect(throws: API.Error.Configuration.self) {
            _ = try urlString.asURL()
        }
    }
}
