import Foundation

extension API {
    public protocol URLConvertible: Sendable {
        func asURL() throws(API.Error.Configuration) -> URL
    }
}

extension String: API.URLConvertible {
    public func asURL() throws(API.Error.Configuration) -> URL {
        guard let url = URL(string: self) else {
            throw API.Error.Configuration.invalidURL(self)
        }
        return url
    }
}

extension URL: API.URLConvertible {
    public func asURL() throws(API.Error.Configuration) -> URL { return self }
}
