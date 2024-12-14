# NetworkKit

이 프로젝트는 **Alamofire**를 기반으로 한 Swift API 클라이언트 모듈입니다.
아래와 같은 문제를 해결하기 위해 설계하였습니다.

1. **복잡한 네트워크 요청 구성**  
   - `Endpoint` 프로토콜로 요청 구성을 표준화.  

2. **비효율적인 디버깅**  
   - `APILogger`를 통해 명확하고 가독성 높은 로깅 제공.  

3. **비일관적인 오류 처리**
   - `APIError` 구조체를 활용해 통합된 오류 관리.  

4. **토큰 관리 문제**
   - `APIInterceptor`로 토큰 자동 추가 및 재갱신 처리.  

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
