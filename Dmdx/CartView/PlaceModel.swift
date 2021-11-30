//
//  PlaceModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 29.11.2021.
//

import Foundation
import Firebase

struct Place: Identifiable, Hashable {
    let id: String
    let name: String
    let city: String
    
    
    init(getPlaceSnapshot: QueryDocumentSnapshot) {
        self.id = getPlaceSnapshot.documentID
        self.name = getPlaceSnapshot["name"] as? String ?? ""
        self.city = getPlaceSnapshot["city"] as? String ?? ""
    }
}
