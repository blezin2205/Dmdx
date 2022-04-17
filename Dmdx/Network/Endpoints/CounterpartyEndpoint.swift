//
//  CounterpartyEndpoint.swift
//  Dmdx
//
//  Created by admin on 06.04.2022.
//

import Foundation

enum CounterpartyType: String {
    case sender = "Sender"
    case recipient = "Recipient"
}

enum CounterpartyEndpoint {
    case getMyCounterparties(type: CounterpartyType)
    case getCounterpartyPersons(type: CounterpartyType, counterpartyId: String)
}

extension CounterpartyEndpoint: Endpoint {
    var path: String {
        ""
    }
    
    var method: RequestMethod {
        switch self {
        case .getMyCounterparties, .getCounterpartyPersons:
            return .post
        }
    }
    
    var body: Parameters? {
        var methodProperties: Parameters
        var bodyData: Parameters {
            ["apiKey": "99f738524ca3320ece4b43b10f4181b1",
                "modelName": "Counterparty",
             "calledMethod": "getCounterparties",
             "methodProperties": methodProperties]
        }
        switch self {
        case .getMyCounterparties(let type):
            methodProperties = ["CounterpartyProperty": type.rawValue]
            return bodyData
        case .getCounterpartyPersons(let type, let counterpartyId):
            methodProperties = ["CounterpartyProperty": type.rawValue, "Ref": counterpartyId]
            return bodyData
        }
    }
}
