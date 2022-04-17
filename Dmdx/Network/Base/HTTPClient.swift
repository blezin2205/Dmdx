//
//  HTTPClient.swift
//  Dmdx
//
//  Created by admin on 06.04.2022.
//

import Foundation

extension Dictionary {
    mutating func lowercaseKeys() {
        for key in self.keys {
            let str = (key as! String).lowercased()
            self[str as! Key] = self.removeValue(forKey: str as! Key)
        }
    }
}

struct NPResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
}

protocol HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint) async -> Result<T, RequestError>
}

extension HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint
    ) async -> Result<T, RequestError> {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
       // request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            switch response.statusCode {
            case 200...299:
                if let json = try JSONSerialization.jsonObject(with: data) as? Parameters {
                    let newDict = Dictionary(uniqueKeysWithValues:
                                                json.map { key, value in (key.lowercased(), value) })
                    let jsonData = try JSONSerialization.data(withJSONObject: newDict)
                    print(newDict)
                    let response = try JSONDecoder().decode(NPResponse<T>.self, from: jsonData)
                    if let _data = response.data {
                        return .success(_data)
                    } else {
                        return .failure(.decode)
                    }
                } else {
                    return .failure(.decode)
                }
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}
