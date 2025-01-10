### 🛜 NetworkKit

이 프로젝트는 **Alamofire**를 기반으로 한 Swift API 클라이언트 모듈입니다.
아래와 같은 문제를 해결하기 위해 설계하였습니다.

`네트워크 요청 코드의 비효율성`
 - 매번 URL, HTTP 메서드, 헤더, 파라미터 등을 수작업으로 작성해야 했음.
 - 요청 코드의 중복과 비일관성으로 인해 유지보수가 어려웠음.

`디버깅 과정의 복잡성`
- 요청 및 응답 정보를 체계적으로 기록하지 않아 디버깅 시간이 증가했음.
- 데이터 포맷이 가독성이 떨어져 문제를 파악하기 어려웠음.

`오류 처리 방식의 일관성 부족`
- 각기 다른 오류 처리 방식으로 인해 코드가 복잡해지고 유지보수가 어려웠음.
- 상태 코드와 메시지를 체계적으로 관리하지 못했음.

`토큰 관리의 어려움`
- 요청마다 토큰을 수동으로 추가하거나 갱신해야 했음.
- 토큰 갱신 실패 시 재시도 로직이 체계적으로 관리되지 않았음.

## 🧩 사용 예시

### Endpoint 정의
```swift
enum UserEndpoint {
    case info
}
struct UserEndpoint: Endpoint {
    var baseURL: String { Env.BaseURL }
    var method: HTTPMethod {
        switch self {
        case .info: .get
        }
    }
    var path: String {
        switch self {
        case .info: ""
        }
    }
    var queryItems: [URLQueryItem]? { nil }
    var headers: HTTPHeaders? { nil }
    var body: Parameters? { nil }
    var token: String? { nil }
    var multipart: MultipartFormData? { nil }
}
```
### APIClient 정의
```swift
let endpoint = UserEndpoint()
let client = APIClient(session: Session())

Task {
    do {
        let response: ExampleResponse = try await client.request(endpoint, decode: UserResponse.self)
        print("✅ 성공: \(response)")
    } catch {
        print("❌ 실패: \(error)")
    }
}
```
