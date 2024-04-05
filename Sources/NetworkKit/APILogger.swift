//
//  File.swift
//  
//
//  Created by 송형욱 on 4/5/24.
//

import Foundation
import Alamofire

struct APILogger: EventMonitor {
    let queue = DispatchQueue(label: "apiLogger")
    
    func requestDidFinish(_ request: Request) {
        #if DEBUG
        print("🚀 NETWORK Reqeust LOG")
        print(request.description)
        
        print(
            "URL:" + (request.request?.url?.absoluteString ?? "")  + "\n"
            + "Method:" + (request.request?.httpMethod ?? "") + "\n"
            + "Headers:" + "\(request.request?.allHTTPHeaderFields ?? [:])" + "\n"
        )
        print("Authorization:" + (request.request?.headers["Authorization"] ?? "nil"))
        print("Body:" + (request.request?.httpBody?.prettyJson ?? "nil"))
        #endif
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        print("✅ NETWORK Response LOG")
        print(
          "URL: " + (request.request?.url?.absoluteString ?? "nil") + "\n"
            + "Result: " + "\(response.result)" + "\n"
            + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
            + "Data: \(response.data?.prettyJson ?? "nil")"
        )
        #endif
    }
}

fileprivate extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}
