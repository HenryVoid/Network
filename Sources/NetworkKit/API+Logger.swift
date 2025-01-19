import Foundation

@available(iOS 17.0, *)
extension API {
    public protocol Loggable: Sendable {
        func request(_ request: URLRequest)
        func response(response: API.Response)
        func response(error: Swift.Error)
    }
    
    public struct Logger: Sendable {
        public static let shared: Logger = .init()
    }
}

@available(iOS 17.0, *)
extension API.Logger: API.Loggable {
    
    public func request(_ request: URLRequest) {
        #if DEBUG
        print("🚀 NETWORK Reqeust LOG")
        print(payload())
        print(request.description)
        
        print("URL:", request.url?.absoluteString ?? "")
        print("Method:", request.httpMethod ?? "")
        print("Headers:", request.allHTTPHeaderFields ?? [:])
        print("Authorization:" + (request.allHTTPHeaderFields?["Authorization"] ?? "nil"))
        print("Body:" + (request.httpBody?.prettyJson ?? "nil"))
        #endif
    }
    
    public func response(response: API.Response) {
        print("✅ NETWORK Response LOG")
        print(payload())
        print("StatusCode:", response.response.statusCode() ?? 0)
        print("Data:", response.data.prettyJson ?? "nil")
    }
    
    public func response(error: Swift.Error) {
        print("❌ NETWORK Response Error LOG")
        print(payload())
        print("Error:", error)
    }
    
    private func payload(
        file: String = #file,
        function: String = #function
    ) -> String {
        let fileName = URL(string: file)?.lastPathComponent ?? file
        return "\n[\(currentTime())]\n\(fileName)-\(function)"
    }
    
    private func currentTime(
        formatter: DateFormatter = .init(),
        dateFormat: String = "yy.MM.dd HH:mm:ss.SSS"
    ) -> String {
        formatter.dateFormat = dateFormat
        return formatter.string(from: .now)
    }
}

fileprivate extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}
