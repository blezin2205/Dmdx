//
//  TabView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 22.11.2021.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var cartViewModel =  CartViewModel()
    var body: some View {
            TabView {
                SuppliesListView(fromOrderView: false)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Склад")
                    }
             
                OrdersView(place: nil)
                    .tabItem {
                        Image(systemName: "bookmark.circle.fill")
                        Text("Отправки")
                    }
                
                ServiceView()
                    .tabItem {
                        Image(systemName: "doc.badge.gearshape")
                        Text("Сервис")
                    }
                
                CartView(cartVM: cartViewModel)
                    .tabItem {
                        Image(systemName: "cart")
                        Text("Корзина")
                    }.badge(cartViewModel.cartCount)
                
                
                
                
            }
            .environmentObject(cartViewModel)
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

extension Date {
    
    func getStringTime() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        return formatter1.string(from: self)
    }
}
