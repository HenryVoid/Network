//
//  APIClient.swift
//  
//
//  Created by 송형욱 on 4/5/24.
//

import Foundation
import Alamofire

final class APIClient: APIProtocol {
    
    public init() {}
    
    private var session: Session {
        let configuration = URLSessionConfiguration.af.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60 // seconds that a task will wait for data to arrive
        configuration.timeoutIntervalForResource = 300 // seconds for whole resource request to complete ,.
        return Session(configuration: configuration, eventMonitors: [APILogger()])
    }
    
    func request<T: Decodable>(_ endpoint: Router, decode: T.Type) async throws -> T {
        do {
            let result = try await self.session.request(endpoint.asURLRequest()).serializingData().response
            return try self.manageResponse(data: result.data, response: result.response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(
                errorCode: "ERROR",
                message: "Unknown API error \(error.localizedDescription)"
            )
        }
    }
}

extension APIClient {
    // MARK: Private
    
    private func manageResponse<T: Decodable>(data: Data?, response: HTTPURLResponse?) throws -> T {
        guard let response else {
            throw APIError(
                errorCode: "ERROR",
                message: "Invalid HTTP response"
            )
        }
        guard let data else {
            throw APIError(
                errorCode: "ERROR",
                message: "Unknown Data Response"
            )
        }
        switch response.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                debugPrint("‼️", error)
                throw APIError(
                    errorCode: "Decoding Data Error Code",
                    message: "Error decoding data"
                )
            }
        default:
            guard let decodedError = try? JSONDecoder().decode(APIError.self, from: data) else {
                throw APIError(
                    statusCode: response.statusCode,
                    errorCode: "ERROR",
                    message: "Unknown backend error"
                )
            }
            
            throw APIError(
                statusCode: response.statusCode,
                errorCode: decodedError.errorCode,
                message: decodedError.message
            )
        }
    }
}
