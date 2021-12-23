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
    let place: Place?
    
    
    var body: some View {
        
            ZStack {
                if place == nil {
                    NavigationView {
                    ZStack {
                        switch orderVM.sortOption {
                        case .all:
                            List(orderVM.orders) { order in
                                NavigationLink(destination: OrdersDetailView(order: order)) {
                                    OrderCellView(vm: orderVM, order: order)
                                }
                                .swipeActions(allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        orderVM.deleteOrder(orderId: order.documntId)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                            .onAppear {
                                orderVM.getOrdersList(forPlace: place)
                            }
                        case .categories:
                            List(orderVM.places) { place in
                                NavigationLink(destination: OrdersView(place: place)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(place.name)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                        Text(place.city)
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                    }
                                }
                            }.onAppear {
                                orderVM.getPlaces()
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Отправки")
                    .toolbar {
        //                ToolbarItem(placement: .navigationBarTrailing) {
        //                    Button {
        //                        showingSheet.toggle()
        //                    } label: {
        //                        Image(systemName: "plus")
        //                    }.opacity(fromOrderView ? 0 : 1)
        //                }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Picker("", selection: $orderVM.sortOption) {
                                ForEach(orderVM.sortOptionArray, id: \.self) {
                                                Text($0.rawValue)
                                            }
                                        }
                                        .pickerStyle(.menu)
                        }
                        
                    }
                }
                } else {
                    List(orderVM.orders) { order in
                        NavigationLink(destination: OrdersDetailView(order: order)) {
                            OrderCellView(vm: orderVM, order: order)
                        }
                        .swipeActions(allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                orderVM.deleteOrder(orderId: order.documntId)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        orderVM.getOrdersList(forPlace: place)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    VStack {
                                        Text(place!.name).font(.headline)
                                        Text(place!.city).font(.subheadline)
                                    }
                                }
                            }
                }
        }
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
                if let comment = order.commentText {
                    Text("( \(comment) )")
                        .font(.subheadline)
                        .padding(.bottom, 4)
                }
                    
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

