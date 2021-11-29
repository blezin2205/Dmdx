//
//  OrdersDetailViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 26.11.2021.
//

import Foundation
import Firebase

class OrdersDetailViewModel: ObservableObject {
    
    
    let db = Firestore.firestore()
    @Published var suppliesInOrder = [Supply]()
    @Published var suppliesInGeneralData = [Supply]()
    @Published var arrayOfBoolen: [Bool] = Array.init(repeating: false, count: 1)
    
    
    func getSuppliesInTheOrder(order: Order) {
        let ref = db.collection("orders").document(order.documntId).collection("supplies")
        ref.getDocuments { snapshot, error in
            if let snap = snapshot {
                self.suppliesInOrder = snap.documents.map {
                    Supply(getSupplyINorder: $0)
                }
                if !order.isComplete {
                    print(#function)
                    self.getActualCountOfSupplies()
                }
            } else {
                print(#function, error?.localizedDescription ?? "")
            }
            
        }
        }
    
    func getActualCountOfSupplies() {
        let suppliesRef = db.collection("supplies")
        let documentsId = suppliesInOrder.map {$0.id}
        suppliesRef.whereField(FieldPath.documentID(), in: documentsId).getDocuments { snap, error in
            if let snapshot = snap {
                let generalSupplies = snapshot.documents.map({ supply in
                    Supply(setSupply: supply)
                })
                self.createNewArray(suppliesInStorage: generalSupplies)
                
            } else {
                print(#function, error?.localizedDescription ?? "")
            }
            
        }
    }
    
    func createNewArray(suppliesInStorage: [Supply]) {
        for (index, element) in suppliesInStorage.enumerated() {
            if self.suppliesInOrder[index].id == element.id {
                self.suppliesInOrder[index].totalCount = element.totalCount + suppliesInOrder[index].count - (element.countOnHold ?? 0)
//                print("=======FOR \(element.name) =======")
//                print("Total count = ", element.totalCount)
//                print("Count = ", suppliesInOrder[index].count)
//                print("Count on Hold = ", element.countOnHold)
//                print("==================================")
              //  self.arrayOfBoolen[index] = self.suppliesInOrder[index].count <= element.totalCount
            }
        }
    }
    
    func updateOrder(orderId: String) {
        let butch = self.db.batch()
        let orderRef = db.collection("orders").document(orderId)
        suppliesInOrder.enumerated().forEach { index, supply in
            let docRef = db.collection("supplies").document(supply.id)
            butch.setData(supply.saveToOrders(), forDocument: orderRef.collection("supplies").document(supply.id))
            let deltaCount = supply.count - (supply.countOnHold ?? 0)
           // suppliesInOrder[index].totalCount += deltaCount
            butch.updateData(["countOnHold": FieldValue.increment(Int64(deltaCount))], forDocument: docRef)
        }
        butch.commit(completion: { (error) in
                if let error = error {
                    print("\(error)")
                } else {
                    print("success")
                    self.getActualCountOfSupplies()
                }
            })
    }
    
    func sendOrder(orderId: String, complition: @escaping () -> Void) {
        let butch = self.db.batch()
        let orderRef = db.collection("orders").document(orderId)
        suppliesInOrder.forEach { supply in
            let docRef = db.collection("supplies").document(supply.id)
            butch.updateData(["count": FieldValue.increment(Int64(-supply.count))], forDocument: docRef)
            butch.updateData(["countOnHold": FieldValue.increment(Int64(-supply.count))], forDocument: docRef)
        }
        butch.updateData(["isComplete": true], forDocument: orderRef)
        butch.commit(completion: { (error) in
                if let error = error {
                    print("\(error)")
                } else {
                    complition()
                    print("success", #function)
                }
            })
          
    }
    
    func deleteSupplyInOrder(orderId: String, supply: Supply) {
        let butch = self.db.batch()
        let docRef = db.collection("supplies").document(supply.id)
        let ref = db.collection("orders").document(orderId).collection("supplies").document(supply.id)
        butch.updateData(["countOnHold": FieldValue.increment(Int64(-supply.count))], forDocument: docRef)
        butch.deleteDocument(ref)
        butch.commit(completion: { (error) in
                if let error = error {
                    print("\(error)")
                } else {
                    if let index = self.suppliesInOrder.firstIndex(where: {$0.id == supply.id}) {
                        self.suppliesInOrder.remove(at: index)
                        print("success with local Remove from Array", #function)
                    }
                    print("success", #function)
                }
            })
        
    }
    

    func cancelOrder(orderId: String, complition: @escaping () -> Void) {
        
        suppliesInOrder.forEach { supply in
            print(supply)
        }
        
        let ref = db.collection("orders").document(orderId)
        let suppliesRef = db.collection("supplies")
        let butch = self.db.batch()
        butch.deleteDocument(ref)
        suppliesInOrder.forEach { supply in
            butch.updateData(["count": FieldValue.increment(Int64(supply.totalCount))], forDocument: suppliesRef.document(supply.id))
        }
        butch.commit(completion: { (error) in
                if let error = error {
                    print("\(error)")
                } else {
                    self.suppliesInOrder.removeAll()
                    complition()
                    print("success")
                   // complition()
                }
            })
        
        
    }
    }


