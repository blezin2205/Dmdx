//
//  OrdersViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 26.11.2021.
//

import Foundation
import Firebase

class OrdersViewModel: ObservableObject {

    let db = Firestore.firestore()
    @Published var orders = [Order]()
    @Published var sortedOrders = [Supply]()
    @Published var ordersForPlace = [Order]()
    @Published var places = [Place]()

    
    enum SortOption: String, RawRepresentable, CaseIterable {
        case all = "Все заказы"
        case categories = "Клиенты"
    }
    @Published var sortOption: SortOption = .all
    let sortOptionArray = SortOption.allCases
    
    
    func getOrdersList(forPlace place: Place?) {
        var ordersRef: Query
        ordersRef = db.collection("orders")
        if let place = place {
            ordersRef = db.collection("orders").whereField("name", isEqualTo: place.name).whereField("city", isEqualTo: place.city)
        }
        ordersRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else {return}
                self.orders = snapshot.documents.map { element in
                    Order(setSupply: element)}.sorted(by: {$0.id > $1.id})
            }
        }
    }
    
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
    
    
    func updateStatus(id: String, isComplete: Bool) {
        db.collection("orders").document(id).updateData(["isComplete": isComplete]) { error in
            if let error = error {
                print(error)
            } else {
//                if let index = self.sortedOrders.firstIndex(where: {$0.documntId == id}) {
//                    self.orders[index].isComplete = isComplete
//                    print(self.sortedOrders)
//                }
            }
            
        }
    }
    
    
    func deleteOrder(orderId: String) {
        let ref = db.collection("orders").document(orderId).collection("supplies")
        let butch = self.db.batch()
        ref.getDocuments { snapshot, error in
            if let snap = snapshot {
                let supplyInOrder = snap.documents.map {
                    Supply(getSupplyINorder: $0)
                }
                supplyInOrder.forEach { supply in
                    let docRef = self.db.collection("supplies").document(supply.id)
                    butch.updateData(["countOnHold": FieldValue.increment(Int64(-supply.count))], forDocument: docRef)
                }
                butch.commit(completion: { (error) in
                        if let error = error {
                            print("\(error)")
                        } else {
                            self.db.collection("orders").document(orderId).delete { error in
                                if let error = error {
                                    print(error)
                                } else if let index = self.orders.firstIndex(where: {$0.documntId == orderId}) {
                                    self.orders.remove(at: index)
                                    print("success", #function)
                                } else {
                                    print("Index not Found")
                                }
                            }
                            
                        }
                    })
            } else {
                print(#function, error?.localizedDescription ?? "")
            }
            
        }
        
        
    }
}


class Order: Identifiable {
    let documntId: String
    let id: Int
    let place: Place
    let dateCreated: Date
    var isComplete: Bool
    let commentText: String?
    
    func convertToDictionary() -> [String: Any] {
        guard let comment = commentText else {
            return ["orderId": id, "name": place.name, "city": place.city, "dateCreated": Timestamp(date: dateCreated), "dateSent": Timestamp(date: Date()), "isComplete": isComplete]
        }
        return ["orderId": id, "name": place.name, "city": place.city, "dateCreated": Timestamp(date: dateCreated), "dateSent": Timestamp(date: Date()), "isComplete": isComplete, "comment": comment]
    }
    
    init(id: Int, place: Place, dateCreated: Date, isComplete: Bool, commentText: String?) {
        self.id = id
        self.place = place
        self.dateCreated = dateCreated
        self.isComplete = isComplete
        self.documntId = ""
        self.commentText = commentText
    }
    
    init(setSupply: QueryDocumentSnapshot) {
        self.documntId = setSupply.documentID
        self.id = setSupply["orderId"] as? Int ?? 0
        self.place = Place(getPlaceSnapshot: setSupply)
        self.dateCreated = (setSupply["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        self.isComplete = setSupply["isComplete"] as? Bool ?? false
        self.commentText = setSupply["comment"] as? String
    }
}

