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
    @Published var places = [String]()

    
    
    func getOrdersList() {
        db.collection("orders").getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else {return}
                self.orders = snapshot.documents.map { element in
                    Order(setSupply: element) }.sorted(by: {$0.id > $1.id})
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
        db.collection("orders").document(orderId).delete { error in
            if let error = error {
                print(error)
            } else if let index = self.orders.firstIndex(where: {$0.documntId == orderId}) {
                self.orders.remove(at: index)
            } else {
                print("Index not Found")
            }
        }
    }
}


class Order: Identifiable {
    let documntId: String
    let id: Int
    let place: String
    let dateCreated: Date
    var isComplete: Bool
    
    func convertToDictionary() -> [String: Any] {
        return ["id": id, "place": place, "dateCreated": Timestamp(date: dateCreated), "isComplete": isComplete]
    }
    
    init(id: Int, place: String, dateCreated: Date, isComplete: Bool) {
        self.id = id
        self.place = place
        self.dateCreated = dateCreated
        self.isComplete = isComplete
        self.documntId = ""
    }
    
    init(setSupply: QueryDocumentSnapshot) {
        self.documntId = setSupply.documentID
        self.id = setSupply["id"] as? Int ?? 0
        self.place = setSupply["place"] as? String ?? ""
        self.dateCreated = (setSupply["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        self.isComplete = setSupply["isComplete"] as? Bool ?? false
    }
}
