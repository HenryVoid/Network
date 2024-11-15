//
//  APIInterceptor.swift
//
//
//  Created by 송형욱 on 4/6/24.
//

import Foundation
import Alamofire

public protocol TokenRefreshable: Sendable {
    func readToken() -> String?
    func refreshToken() async -> Bool
}

@available(macOS 10.15, *)
final class APIInterceptor: RequestInterceptor {
    
    private let tokenRefresher: TokenRefreshable
    
    init(tokenRefresher: TokenRefreshable) {
        self.tokenRefresher = tokenRefresher
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        
        guard let token = tokenRefresher.readToken(), !token.isEmpty else { // Get token
            completion(.success(request))
            return
        }
        
        request.headers.add(.authorization(bearerToken: token))
        
        if let tokenHeader = request.headers.first(where: { $0 == .authorization(bearerToken: token) }) {
            print("\nadapted; token added to the header field is: \(tokenHeader)\n")
        }
        
        completion(.success(request))
    }
    
    func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: any Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        let retryLimit = 3
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }
        print("\nretried; retry count: \(request.retryCount)\n")
        
        Task {
            let getRefreshToken = await self.tokenRefresher.refreshToken()
            getRefreshToken ? completion(.retry) : completion(.doNotRetry)
        }
    }
}
