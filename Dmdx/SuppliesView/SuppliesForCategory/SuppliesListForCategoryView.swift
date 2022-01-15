//
//  SuppliesListForCategoryView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 23.11.2021.
//

import SwiftUI

struct SuppliesListForCategoryView: View {
    @StateObject var vm: SuppliesForCategoryViewModel
    let fromOrderView: Bool
    let category: String
    let suppliesToCompare: [Supply]?
    let addComplition: ((Supply) -> Void)?
    
    init(fromOrderView: Bool, category: String, suppliesToCompare: [Supply]?, addComplition: ((Supply) -> Void)?) {
        self.fromOrderView = fromOrderView
        self.category = category
        self.suppliesToCompare = suppliesToCompare
        self.addComplition = addComplition
        _vm = StateObject.init(wrappedValue: SuppliesForCategoryViewModel(fromOrderView: fromOrderView))
    }
    
    var body: some View {
        List(vm.sortedSuppliesForCategory) { supply in
            if fromOrderView {
                SupplyCellView(supply: supply, viewForCart: false, fromOrderView: fromOrderView, addToNote: suppliesToCompare?.contains(where: {$0.id == supply.id}) ?? false, addComplition: addComplition)
            } else {
                NavigationLink(destination: AddNewOneView(viewModel: ViewModel(fromOrderView: fromOrderView), supply: supply, addNewLot: false)) {
                    SupplyCellView(supply: supply, viewForCart: false, fromOrderView: fromOrderView, addComplition: nil)
                }
            }
        }.onAppear {
            vm.getDataforCategory(category: category)
        }
        .listStyle(PlainListStyle())
        .navigationTitle(category)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Picker("", selection: $vm.sortOption) {
                    ForEach(vm.sortOptionArray, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
            }
        }
}
}
