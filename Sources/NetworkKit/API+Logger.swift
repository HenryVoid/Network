import Foundation

extension API {
    protocol Loggable {
        func request(_ request: URLRequest)
        func response(_ request: URLRequest, data: Data, response: URLResponse)
        func response(_ request: URLRequest, error: API.Error)
    }
    
    struct Logger {
        static let shared: Logger = .init()
    }
}

extension API.Logger: API.Loggable {
    
    func request(_ request: URLRequest) {
        #if DEBUG
        print("🚀 NETWORK Reqeust LOG")
        print(payload())
        print(request.description)
        
        print(
            "URL:" + (request.request?.url?.absoluteString ?? "")  + "\n"
            + "Method:" + (request.request?.httpMethod ?? "") + "\n"
            + "Headers:" + "\(request.request?.allHTTPHeaderFields ?? [:])" + "\n"
        )
        print("Authorization:" + (request.request?.headers["Authorization"] ?? "nil"))
        print("Body:" + (request.request?.httpBody?.prettyJson ?? "nil"))
        #endif
    }
    
    func response(_ request: URLRequest, data: Data, response: URLResponse) {
        print("✅ NETWORK Response LOG")
        print(payload())
        print(
          "URL: " + (request.request?.url?.absoluteString ?? "nil") + "\n"
            + "Result: " + "\(response.result)" + "\n"
            + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
            + "Data: \(response.data?.prettyJson ?? "nil")"
        )
    }
    
    func response(_ request: URLRequest, error: API.Error) {
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
