# Network

### DTO

Codable 상속받고, 서버에서 요청하는 Raw 형태로 정의한다.
(변경 시 History를 남기기위한 것이며, 각 feature에서 쓸 때는 가공해서 쓰는 것으로)

```
// MembershipDTO.swift
enum MembershipDTO {
	enum Info {}
}

// MembershipDTO+Info.swift
extension MembershipDTO.Info {
	struct Request: Encodable {}
	struct Response: Decodable {}
}
```

### Endpoint

Path 별 어떻게 사용하는 지 명확하게 구분한다.

```
// MembershipEndpoint.swift

enum MembershipEndpoint {
    case info(id: String)
}

extension MembershipEndpoint: Endpoint {
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .info: .get
        }
    }
    
    public var path: String {
        switch self {
        case .info:
            return "/api/info"
        }
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .info: nil
        }
    }
    
    public var headers: Alamofire.HTTPHeaders? {
        switch self {
        case .info: nil
        }
    }
    
    public var body: Alamofire.Parameters? {
        switch self {
        case .info(let id):
            return ["id": id]
        }
    }
    
    public var multipart: Alamofire.MultipartFormData? { nil }
}
```
