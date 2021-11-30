//
//  CartViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 25.11.2021.
//

import Foundation
import Combine
import Firebase

class CartViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    @Published var cart = [Supply]()
    @Published var cartCount = Int()
    @Published var cartCountSupply = 0
    @Published var places = [Place]()
    @Published var selectedPlace: Place?
    private let cartKeyUserDef = "cartItems"
    @Published var idForOrder: Int = 0
    
    init() {
        fetchTotalCountOfOrders()
        getSuppliesFromUserDef()
        addSubscribers()
        getPlaces()
    }
    
    func addSubscribers() {
        $cart
            .sink(receiveValue: { [weak self] suppleArray in
                guard let self = self else { return }
                self.cartCount = suppleArray.count
                self.cartCountSupply = suppleArray.map {$0.count}.reduce(0, +)
            })
            .store(in: &cancellables)
    }
    
    func deleteCart() {
        self.cart.removeAll()
        self.selectedPlace = nil
        UserDefaults.standard.removeObject(forKey: cartKeyUserDef)
    }
    
    func addSupplyToCart(supply: Supply) {
        print(supply)
        cart.append(supply)
        saveSuppliesToSerDefaults()
    }

    
    func saveSuppliesToSerDefaults() {
        if let encodedData = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(encodedData, forKey: cartKeyUserDef)
        }
    }
    
    func getSuppliesFromUserDef() {
        guard let data = UserDefaults.standard.data(forKey: cartKeyUserDef),
        let cartItems = try? JSONDecoder().decode([Supply].self, from: data)
        else {return}
        self.cart = cartItems
        
    }
    
    func getPlaces() {
        db.collection("places").getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot {
                    self.places = snapshot.documents.map({ item in
                        let place = Place(getPlaceSnapshot: item)
                        return place
                    })
                }
            }
        }
    }
    
    func fetchTotalCountOfOrders() {
        db.collection("orders").addSnapshotListener { snapshot, erorr in
            if let snapshot = snapshot {
                self.idForOrder = snapshot.documents.count + 1
            }
        }
    }
    
    
    func updateDBforCart(complition: @escaping () -> Void) {
        
        let order = Order(id: idForOrder, place: selectedPlace!, dateCreated: Date(), isComplete: false)
        
        let orderRef = db.collection("orders").document()
        orderRef.setData(order.convertToDictionary())
        let butch = self.db.batch()
        
        cart.forEach { supply in
            let docRef = db.collection("supplies").document(supply.id)
            butch.updateData(["countOnHold": FieldValue.increment(Int64(supply.count))], forDocument: docRef)
          //  butch.updateData(["countOnHold": supply.count], forDocument: docRef)
            butch.setData(supply.saveToOrders(), forDocument: orderRef.collection("supplies").document(supply.id))
            
        }
        butch.commit(completion: { (error) in
                if let error = error {
                    print("\(error)")
                } else {
                    self.deleteCart()
                    print("success")
                    complition()
                }
            })
        
        
        
    }
}


