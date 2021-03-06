//
//  SuppliesForCategoryViewModel.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 23.11.2021.
//

import Foundation
import Firebase
import Combine

class SuppliesForCategoryViewModel: ObservableObject {
    
    enum SortOption: String, RawRepresentable, CaseIterable {
        case all = "Все товары"
        case onlyExpired = "Только просроченные"
        case onlyGood = "Только годные"
        
    }
    @Published var sortOption: SortOption = .all
    let sortOptionArray = SortOption.allCases
    
    @Published var suppliesForCategory = [Supply]()
    @Published var sortedSuppliesForCategory = [Supply]()
    let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private let fromOrderView: Bool
    
    init(fromOrderView: Bool) {
        self.fromOrderView = fromOrderView
        addSubscribers()
    }
    
    
    func addSubscribers() {
        $sortOption
            .combineLatest($suppliesForCategory)
            .map (filterSupplies)
            .sink { [weak self] (returnedCoins) in
                self?.sortedSuppliesForCategory = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    func getDataforCategory(category: String) {
        db.collection("supplies").whereField("device", isEqualTo: category).getDocuments { snapshot, error in
            if let snapshot = snapshot {
                var suppies = snapshot.documents.map({ Supply(setSupply: $0) })
                if self.fromOrderView {
                    suppies = suppies.filter({$0.totalCount > 0})
                }
                self.suppliesForCategory = suppies
            }
        }
    }
    
    
    private func filterSupplies(sortOption: SortOption,  supplies: [Supply]) -> [Supply] {
        switch sortOption {
        case .all:
           return supplies.sorted(by: {$0.expiredDate > $1.expiredDate})
        case .onlyExpired:
            return supplies.filter {$0.expiredDate < Date()}.sorted(by: {$0.expiredDate > $1.expiredDate})
        case .onlyGood:
            return supplies.filter {$0.expiredDate > Date()}.sorted(by: {$0.expiredDate > $1.expiredDate})
        }
    }
}
