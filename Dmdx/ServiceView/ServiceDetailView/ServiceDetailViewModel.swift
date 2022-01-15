//
//  ServiceDetailViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 12.01.2022.
//

import Foundation
import Firebase

class ServiceDetailViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    @Published var serviceNotes = [ServiceModel]()
    @Published var commentText = ""
    @Published var supplisForNote = [Supply]()
    
    let placeId: String
    
    init(placeId: String) {
        self.placeId = placeId
        getServiceNote()
    }
    
    func getServiceNote() {
        db.collection("places").document(placeId).collection("serviceNotes").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else {return}
                self.serviceNotes = snapshot.documents.map { element in
                   ServiceModel(setServiceNote: element)
            }
        }
    }
    }
    
    func addNoteToPlace(complition: @escaping () -> Void) {
        let butch = self.db.batch()
        db.collection("places").document(placeId).collection("serviceNotes").addDocument(data: ServiceModel(comment: commentText, dateCreated: Date(), supplies: supplisForNote.isEmpty ? nil : supplisForNote).convertToDictionary()) { error in
            if let error = error {
                print(error)
            } else {
                self.supplisForNote.forEach { supp in
                    let docRef = self.db.collection("supplies").document(supp.id)
                    butch.updateData(["count": FieldValue.increment(Int64(-supp.count))], forDocument: docRef)
                }
                butch.commit(completion: { (error) in
                        if let error = error {
                            print("\(error)")
                        } else {
                            complition()
                            print("success", #function)
                        }
                    })
            }
        }
    }
    
    func deleteComplition(supplyId: String) {
        if let index = supplisForNote.firstIndex(where: {$0.id == supplyId}) {
            supplisForNote.remove(at: index)
        }
    }
}
