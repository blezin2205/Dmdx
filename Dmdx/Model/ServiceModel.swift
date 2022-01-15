//
//  ServiceModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 12.01.2022.
//

import Foundation
import Firebase

struct ServiceModel: Identifiable, Codable {
    let id: String?
    let comment: String
    let dateCreated: Date
    let supplies: [Supply]?
    
    init(comment: String, dateCreated: Date, supplies: [Supply]? = nil) {
        self.id = nil
        self.comment = comment
        self.dateCreated = dateCreated
        self.supplies = supplies
    }
    
    init(setServiceNote: DocumentSnapshot) {
        self.id = setServiceNote.documentID
        self.comment = setServiceNote["comment"] as? String ?? ""
        self.dateCreated = (setServiceNote["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        if let dictSupp = setServiceNote["supplies"] as? [[String: Any]] {
            self.supplies = dictSupp.map({ dictElement in
                Supply(id: "",
                       name: dictElement["name"] as? String ?? "",
                       device: dictElement["device"] as? String ?? "",
                       count: dictElement["count"] as? Int ?? 0,
                       totalCount: dictElement["count"] as? Int ?? 0,
                       dateCreated: (dictElement["dateCreated"] as? Timestamp)?.dateValue() ?? Date(),
                       expiredDate: (dictElement["expiredDate"] as? Timestamp)?.dateValue() ?? Date(),
                       countOnHold: dictElement["countOnHold"] as? Int,
                       supplyLot: dictElement["supplyLot"] as? String)
            })
        } else {
            self.supplies = nil
        }
    }
    
    func convertToDictionary() -> [String: Any] {

        if let suppliesDictionary = supplies?.map({$0.convertToDictionaryForService()}) {
            return ["comment": comment, "dateCreated": Timestamp(date: dateCreated), "supplies": suppliesDictionary ]
        } else {
            return ["comment": comment, "dateCreated": Timestamp(date: dateCreated)]
        }
    }
}
