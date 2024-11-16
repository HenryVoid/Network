# Network

### DTO

Codable 상속받고, 서버에서 요청하는 Raw 형태로 정의한다.
(변경 시 History를 남기기위한 것이며, 각 feature에서 쓸 때는 가공해서 쓰는 것으로)

```
// DTO.swift
enum DTO {
	enum Info {}
}

// DTO+Info.swift
extension DTO.Info {
	struct Request: Encodable {}
	struct Response: Decodable {}
}
```
