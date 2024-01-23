
import Foundation

enum NetworkError: LocalizedError {
    case failConnection
    case invalidURL
    case invalidStatusCode(code: Int)
    case emptyData
    case decodingKeyError(key: String)
    case decodingTypeError(keys: [CodingKey])
    case decodingValueError(keys: [CodingKey])
    case responseError
    case unknownError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .failConnection:
            return "네트워크 연결이 불안정해요"
        case .invalidURL:
            return "유효하지 않은 URL이에요"
        case .invalidStatusCode, .responseError:
            return "나중에 다시 시도해주세요"
        case .emptyData:
            return "유효하지 않은 결과에요"
        case .decodingKeyError(let key):
            return "DECODE: \(key)를 찾을 수 없어요"
        case .decodingTypeError(let keys):
            let text = keys.map { $0.stringValue }.joined(separator: ",")
            return "(\(text))의 타입을 다시 확인해주세요"
        case .decodingValueError(let keys):
            let text = keys.map { $0.stringValue }.joined(separator: ",")
            return "(\(text))의 값을 다시 확인해주세요"
        case .unknownError(let message):
            return message
        }
    }
}
