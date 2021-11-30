//
//  OrdersView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 22.11.2021.
//

import SwiftUI

struct OrdersView: View {
    @State private var selection: String?
    @StateObject var orderVM = OrdersViewModel()
    
    
    var body: some View {
        NavigationView {
            List(orderVM.orders) { order in
                NavigationLink(destination: OrdersDetailView(order: order)) {
                    OrderCellView(vm: orderVM, order: order)
                }
//                .swipeActions(allowsFullSwipe: true) {
//                    Button(role: .destructive) {
//                        orderVM.deleteOrder(orderId: order.documntId)
//                    } label: {
//                        Label("Delete", systemImage: "trash.fill")
//                    }
//                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Отправки")
            .onAppear {
                orderVM.getOrdersList()
            }
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}

struct OrderCellView: View {
    
    @ObservedObject var vm: OrdersViewModel
    let order: Order

    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Заказ №\(order.id)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .overlay(Divider(), alignment: .bottom)
                    
                HStack {
                    Text("Для организации:")
                        .foregroundColor(Color.secondary)
                    Text("\(order.place.name)")
                        .bold()
                }
                .font(.subheadline)
                HStack {
                    Text("Город:")
                        .foregroundColor(Color.secondary)
                    Text("\(order.place.city)")
                        .bold()
                }
                .font(.subheadline)
                .padding(.bottom, 4)
                HStack {
                    Text("Статус:")
                        .foregroundColor(Color.secondary)
                        Text(order.isComplete ? "Отправлен" : "В ожидании")
                        .font(.system(size: 16, weight: .heavy, design: .serif))
                        .foregroundColor(order.isComplete ? .green : .orange)
                }.font(.subheadline)
                HStack {
                    Text("Cоздано:")
                        .foregroundColor(Color.secondary)
                    Text("\(order.dateCreated.toString())")
                }
                    .font(.footnote)
                    .padding(.bottom, 4)

        }
    }
}
