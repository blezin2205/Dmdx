//
//  OrderDetailView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 26.11.2021.
//

import Foundation
import SwiftUI

struct OrdersDetailView: View {
    let order: Order
    @StateObject var vm = OrdersDetailViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert = false
    @State private var editOrder = false
    @State private var ordersIsComplete: Bool
    @State private var alertMessage = ""
    
    init(order: Order) {
        self.order = order
        self._ordersIsComplete = State.init(wrappedValue: order.isComplete)
    }
    
    
    var body: some View {
        VStack {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Для организации:")
                                .foregroundColor(Color.secondary)
                            Text("\(order.place.name)")
                                
                        }.font(.subheadline)
                        HStack {
                            Text("Город:")
                                .foregroundColor(Color.secondary)
                            Text("\(order.place.city)")
                                
                        }.font(.subheadline)
                        
                        HStack {
                            Text("Cоздано:")
                                .foregroundColor(Color.secondary)
                            Text("\(order.dateCreated.toString())")
                               
                        }.font(.footnote)
                        
                    }
                    Spacer()
                    Button {
                        if editOrder {
                            withAnimation {
                                editOrder.toggle()
                            }
                        } else {
                            alertMessage = "Подтвердить отправку товара?"
                            showAlert.toggle()
                        }
                        
                    } label: {
                        if editOrder {
                            Image(systemName: "xmark")
                                .rotationEffect(Angle(degrees: 180))
                            
                        } else {
                            Image(systemName: "paperplane")
                        }
                        
                    }.disabled(ordersIsComplete)
                }.padding()
            }
            
            Section {
                List(vm.suppliesInOrder) { supply in
                    OrderDetailCellView(supply: supply, editOrders: $editOrder, orderIsComplete: $ordersIsComplete, ordersDetailViewModel: vm)
//                        .swipeActions(allowsFullSwipe: false) {
//                            Button(role: .destructive) {
//                                vm.deleteSupplyInOrder(orderId: order.documntId, supply: supply)
//                            } label: {
//                                Label("Delete", systemImage: "trash.fill")
//                            }
//                        }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editOrder ? "Сохранить" : "Редактировать") {
                        if editOrder {
                            vm.updateOrder(orderId: order.documntId)
                        }
                        withAnimation {
                            editOrder.toggle()
                        }
                    }.disabled(ordersIsComplete)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(ordersIsComplete ? "Заказ №\(order.id) " + "🟢" : "Заказ №\(order.id) " + "🟠")
            
            
            
        }.onAppear {
                vm.getSuppliesInTheOrder(order: order)
        }
        .overlay(
            Text("\(vm.suppliesInOrder.map {$0.count}.reduce(0, +))")
                .bold()
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(.white)
                .background(.blue)
                .clipShape(Circle())
                .shadow(radius: 2)
                .padding(16)
            , alignment: .bottomTrailing
        )
        
        
        .alert(alertMessage, isPresented: $showAlert) {
                Button("Ок!") {
                    vm.sendOrder(orderId: order.documntId) {
                        withAnimation {
                            ordersIsComplete = true
                            order.isComplete = true
                        }
                        
                    }
                }
            Button("Oтмена", role: .cancel) { }
        }
        
    }
}

struct OrderDetailCellView: View {
    
    let supply: Supply
    
    @Binding var editOrders: Bool
    @Binding var orderIsComplete: Bool
    @State private var count = 0
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ordersDetailViewModel: OrdersDetailViewModel
    
    
    var body: some View {
        if let cardIndex = ordersDetailViewModel.suppliesInOrder.firstIndex(where: {$0.id == supply.id}) {
            let bindingCount = Binding<Int>(
                get: { ordersDetailViewModel.suppliesInOrder[cardIndex].count },
                set: {
                    ordersDetailViewModel.suppliesInOrder[cardIndex].count = $0
                   
                })
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(supply.name)
                            .font(.system(size: 21, weight: .medium, design: .rounded))
                        if !orderIsComplete {
                            if (supply.totalCount - supply.count) == 0 {
                                Text("Нет доступных едениц!")
                                    .foregroundColor(Color.red)
                                    .font(.footnote)
                            } else {
                                Text("Доступно еще \(supply.totalCount - supply.count)шт!")
                                    .foregroundColor(Color.orange)
                                    .font(.footnote)
                                
                            }
                            
                        }
                    }
                    Text(supply.device)
                        .font(.subheadline)
                        .padding(.bottom, 4)
                    HStack {
                        Text("Срок годности:")
                        Text(supply.expiredDate.toString())
                            .foregroundColor(supply.expiredDate > Date() ? .accentColor : .red)
                    }
                    .font(.footnote)
                    
                }
                Spacer()
                VStack {
                    Text("\(supply.count)")
                        .bold()
                        .padding(.horizontal, 8)
                        .frame(height: 30)
                        .frame(minWidth: 40)
                        .background(colorScheme == .dark ? Color.secondary : Color.white)
                        .cornerRadius(6)
                        .shadow(radius: 2)
                    
                    if editOrders {
                        Stepper("Количество", value: bindingCount, in: 0...supply.totalCount)
                            .labelsHidden()
                        
                        
                    }
                }.padding(.trailing, 12)
                
            }
        }
        
        
        
        
    }
}
