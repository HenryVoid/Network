import Foundation

extension API {
    public typealias HttpHeaders = [API.HttpHeader]
    
    public struct HttpHeader: Hashable, Sendable {
        public let key: String
        public let value: String
        
        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }
}

extension API.HttpHeader {
    public var toDictionaryString: String {
        return "\(key): \(value)"
    }
}

extension API.HttpHeader {
    static func authorization(_ value: String) -> Self {
        return .init(key: "Authorization", value: value)
    }
    static func contentType(value: String) -> Self {
        return .init(key: "Content-Type", value: value)
    }
    static func userAgent(value: String) -> Self {
        return .init(key: "User-Agent", value: value)
    }
}

extension API.HttpHeaders {
    public var dictionary: [String: String] {
        let namesAndValues = self.map { ($0.key, $0.value) }
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}

extension URLRequest {
    mutating public func setHeaders( _ headers: API.HttpHeaders) {
        headers.forEach {
            self.setValue($0.value, forHTTPHeaderField: $0.key)
        }
    }
}
