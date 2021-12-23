//
//  SuppliesModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 25.11.2021.
//

import Foundation
import Firebase

struct Supply: Identifiable, Codable {
    let id: String
    let name: String
    let device: String
    var count: Int
    var totalCount: Int
    let dateCreated: Date
    let expiredDate: Date
    var countOnHold: Int?
    let supplyLot: String?
    
    init(id: String, name: String, device: String, count: Int, totalCount: Int, dateCreated: Date, expiredDate: Date, countOnHold: Int? = nil, supplyLot: String? = nil) {
        self.id = id
        self.name = name
        self.device = device
        self.count = count
        self.totalCount = totalCount
        self.dateCreated = dateCreated
        self.expiredDate = expiredDate
        self.countOnHold = countOnHold
        self.supplyLot = supplyLot
    }
    
    init(setSupply: DocumentSnapshot) {
        self.id = setSupply.documentID
        self.name = setSupply["name"] as? String ?? ""
        self.device = setSupply["device"] as? String ?? ""
        self.totalCount = setSupply["count"] as? Int ?? 0
        self.countOnHold = setSupply["countOnHold"] as? Int
        self.dateCreated = (setSupply["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        self.expiredDate = (setSupply["expiredDate"] as? Timestamp)?.dateValue() ?? Date()
        self.count = 1
        self.supplyLot = setSupply["supplyLot"] as? String
    }
    
    init(getSupplyINorder: QueryDocumentSnapshot) {
        self.id = getSupplyINorder.documentID
        self.name = getSupplyINorder["name"] as? String ?? ""
        self.device = getSupplyINorder["device"] as? String ?? ""
        self.totalCount = getSupplyINorder["countInStorage"] as? Int ?? 0
        self.dateCreated = (getSupplyINorder["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        self.expiredDate = (getSupplyINorder["expiredDate"] as? Timestamp)?.dateValue() ?? Date()
        self.count = getSupplyINorder["countInOrder"] as? Int ?? 0
        self.countOnHold = getSupplyINorder["countInOrder"] as? Int ?? 0
        self.supplyLot = getSupplyINorder["supplyLot"] as? String
    }
    
    func convertToDictionary() -> [String: Any] {
        return ["name": name, "device": device, "count": totalCount, "countOnHold": countOnHold ?? 0, "dateCreated": Timestamp(date: dateCreated), "expiredDate": Timestamp(date: expiredDate), "supplyLot": supplyLot ?? ""]
    }
    
    func saveToOrders() -> [String: Any] {
        return ["name": name, "device": device, "countInOrder": count, "countInStorage": totalCount - count, "dateCreated": Timestamp(date: dateCreated), "expiredDate": Timestamp(date: expiredDate), "dateSent": Timestamp(date: Date()), "supplyLot": supplyLot ?? ""]
    }
    
}
