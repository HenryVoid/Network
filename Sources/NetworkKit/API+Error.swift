import Foundation

extension API {
    public enum Error: Swift.Error, Sendable {
        case encoding(Encoding)
        case configuration(Configuration)
        case decoding(Decoding)
        case session(Session)
        case response(Response)
        case connection(Connection)
        case unknown
    }
}

extension API.Error {
    public enum Encoding: Swift.Error, Sendable {
        case missingURL
        case invalidJSON
        case jsonEncodingFailed
    }
    
    public enum Configuration: Swift.Error, Sendable {
        case invalidURL(API.URLConvertible)
    }
    
    public enum Decoding: Swift.Error, Sendable {
        case failedToDecode(Swift.DecodingError)
        case unknown
    }
    
    public enum Session: Swift.Error, Sendable {
        case failedDataRequest
    }
    
    public enum Response: Swift.Error, Sendable {
        case server(API.Error.ServerError)
        case invalidResponse
        case invalidStatusCode(Int)
    }
    
    public enum Connection: Swift.Error, Sendable {
        case failed
    }
    
    public struct ServerError: Swift.Error, Sendable {
        public let statusCode: Int
        public let errorCode: String
        public let message: String
        
        public init(statusCode: Int = 0, errorCode: String, message: String) {
            self.statusCode = statusCode
            self.errorCode = errorCode
            self.message = message
        }
        
        private enum CodingKeys: String, CodingKey {
            case errorCode
            case message
        }
    }
}

extension API.Error.ServerError: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try container.decode(String.self, forKey: .errorCode)
        message = try container.decode(String.self, forKey: .message)
        statusCode = 0
    }
}
