//
//  ServiceViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 12.01.2022.
//

import SwiftUI
import Firebase

class ServiceViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    @Published var places = [Place]()
    @Published var city = ""
    @Published var name = ""

    
    
    func getPlaces() {
        db.collection("places").getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else {return}
                
                self.places = snapshot.documents.map { element in
                   Place(getPlaceSnapshot: element)
            }
        }
    }
    }
    
    func addNewPlace(complition: @escaping () -> Void) {
        db.collection("places").addDocument(data: Place(name: name, city: city).convertToDictionary()) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                complition()
            }
        }
        
    }
    
}
