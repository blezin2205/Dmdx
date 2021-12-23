//
//  SuppliesListForCategoryView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 23.11.2021.
//

import SwiftUI

struct SuppliesListForCategoryView: View {
    @StateObject var vm = SuppliesForCategoryViewModel()
    let fromOrderView: Bool
    let category: String
    var body: some View {
        List(vm.sortedSuppliesForCategory) { supply in
            NavigationLink(destination: AddNewOneView(viewModel: ViewModel(), supply: supply)) {
                SupplyCellView(supply: supply, viewForCart: false, fromOrderView: fromOrderView)
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
