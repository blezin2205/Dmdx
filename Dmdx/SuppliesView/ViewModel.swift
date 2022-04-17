//
//  ViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 20.11.2021.
//

import Foundation
import Firebase
import Combine

class ViewModel: ObservableObject {
    
    enum SortOption: String, RawRepresentable, CaseIterable {
        case all = "Все товары"
        case categories = "Категории"
        case onlyExpired = "Только просроченные"
        case onlyGood = "Только годные"
        
    }
    @Published var sortOption: SortOption = .all
    let sortOptionArray = SortOption.allCases
    let testService = CounterpartyService()

    let db = Firestore.firestore()
    @Published var supplies = [Supply]()
    @Published var sortedSupplies = [Supply]()
    @Published var devices = [String]()
    @Published var isAlertPresenting = false
    @Published var buttonDisabled = false
    

    @Published var supplyName = ""
    @Published var searchText = ""
    @MainActor @Published var testcounterparty = [Counterparty]()
    var errorMessage = ""
    private var cancellables = Set<AnyCancellable>()
    private let fromOrderView: Bool

    init(fromOrderView: Bool) {
        self.fromOrderView = fromOrderView
        getSuppliesList()
        getDevicesList()
        addSubscribers()
    }
    
    @MainActor func reload() async {
       let result = await testService.getMyCounterparties(type: .sender)
        switch result {
            
        case .success(let arr):
            
            self.testcounterparty = arr
            print(self.testcounterparty)
        case .failure(let err):
            print(err)
        }
    }
    
    func addSubscribers() {
        $supplyName
            .map {$0.count < 3}
            .assign(to: \.buttonDisabled, on: self)
            .store(in: &cancellables)
//
//        $searchText
//            .combineLatest($supplies)
//            .map(filterSupplies)
//            .sink { [weak self] (returnedArray) in
//                self?.supplies = returnedArray
//                print(self?.searchText)
//            }
//            .store(in: &cancellables)
        
        $sortOption
            .combineLatest($supplies)
            .map (filterSupplies)
            .sink { [weak self] (returnedCoins) in
                self?.sortedSupplies = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    var searchResults: [Supply] {
            if searchText.isEmpty {
                return supplies
            } else {
                return supplies.filter { $0.name.lowercased().contains(searchText) }
            }
        }
    
    private func filterSupplies(sortOption: SortOption,  supplies: [Supply]) -> [Supply] {
        switch sortOption {
        case .all:
           return supplies.sorted(by: {$0.expiredDate > $1.expiredDate})
        case .categories:
            return supplies.sorted(by: {$0.expiredDate > $1.expiredDate})
        case .onlyExpired:
            return supplies.filter {$0.expiredDate < Date()}.sorted(by: {$0.expiredDate > $1.expiredDate})
        case .onlyGood:
            return supplies.filter {$0.expiredDate > Date()}.sorted(by: {$0.expiredDate > $1.expiredDate})
        }
    }
    
    func getSuppliesList() {
        
                db.collection("supplies").addSnapshotListener { [unowned self] snapshot, error in
                    if let snapshot = snapshot {
                        var suppies = snapshot.documents.map({ Supply(setSupply: $0) })
                        if fromOrderView {
                            suppies = suppies.filter({$0.totalCount > 0})
                        }
                        self.supplies = suppies
                    }
                }
    }
    
    func getDevicesList() {
        db.collection("devices").getDocuments { shapshot, error in
            if let snap = shapshot {
                self.devices = snap.documents.map {$0.documentID}
            }
        }
    }
    
    func deleteSupplyById(id: String) {
        db.collection("supplies").document(id).delete()
    }
    
    func addNewElementToDB(supply: Supply, complition: @escaping () -> Void) {
        let supplyRef = db.collection("supplies").document()
        if supplies.contains(where: {$0.name == supply.name && $0.expiredDate.getComponents(.day, .month, .year) == supply.expiredDate.getComponents(.day, .month, .year)}) {
                errorMessage = "Товар с таким названием и сроком годности уже сущестувует в базе. \nВыберите другое название!"
                isAlertPresenting = true
            } else {
                setSupply(ref: supplyRef, supply: supply, complition: complition)
            }
    }
    
    func updateElementById(id: String, newSupply: Supply, oldSupply: Supply) {
        let supplyRef = db.collection("supplies").document(id)
        if newSupply.name != oldSupply.name && supplies.contains(where: {$0.name == newSupply.name && $0.expiredDate.getComponents(.day, .month, .year) == newSupply.expiredDate.getComponents(.day, .month, .year)}) {
            errorMessage = "Товар с таким названием и сроком годности уже сущестувует в базе. \nВыберите другое название!"
            isAlertPresenting = true
        } else {
            setSupply(ref: supplyRef, supply: newSupply) {}
        }
        
    }
    
    func setSupply(ref: DocumentReference, supply: Supply, complition: @escaping () -> Void) {
        ref.setData(supply.convertToDictionary()) { [unowned self] error in
            if let error = error {
                errorMessage = error.localizedDescription
                isAlertPresenting = true
            } else {
                print("Added Successfully")
                complition()
            }
            
        }
    }

    
}


