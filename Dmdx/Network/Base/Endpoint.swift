//
//  Endpoint.swift
//  Dmdx
//
//  Created by admin on 06.04.2022.
//

import Foundation

typealias Parameters = [String: Any]

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: Parameters? { get }
    var body: Parameters? { get }
}

extension Endpoint {
    var baseURL: String {
        return "https://api.novaposhta.ua/v2.0/json/"
    }
    
    var header: Parameters? {
            return [
                "Content-Type": "application/json;charset=utf-8"
            ]
    }
    
}
