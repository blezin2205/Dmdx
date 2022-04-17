//
//  ContentView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 20.11.2021.
//

import SwiftUI




struct SuppliesListView: View {
    
    @StateObject var vm: ViewModel
    @State private var showingSheet = false
    @State private var searchText = ""
    let fromOrderView: Bool
    
    @Environment(\.presentationMode) var presentationMode
    let supplyForNewLot: Supply?
    let addComplition: ((Supply) -> Void)?
    let suppliesToCompare: [Supply]?
    
    init(fromOrderView: Bool, supplyForNewLot: Supply? = nil, suppliesToCompare: [Supply]? = nil, addComplition: ((Supply) -> Void)? = nil) {
        self.fromOrderView = fromOrderView
        self.supplyForNewLot = supplyForNewLot
        self.suppliesToCompare = suppliesToCompare
        self.addComplition = addComplition
        self._vm = StateObject.init(wrappedValue: ViewModel(fromOrderView: fromOrderView))
    }
    
    
    var body: some View {
        NavigationView {
            
            ZStack {
                
                switch vm.sortOption {
                case .all, .onlyExpired, .onlyGood:
                    List(searchResults) { supply in
                        if fromOrderView {
                            SupplyCellView(supply: supply, viewForCart: false, fromOrderView: fromOrderView, addToNote: suppliesToCompare?.contains(where: {$0.id == supply.id}) ?? false, addComplition: addComplition)
                                
                        } else {
                            NavigationLink(destination: AddNewOneView(viewModel: vm, supply: supply, addNewLot: false)) {
                                SupplyCellView(supply: supply, viewForCart: false, fromOrderView: fromOrderView, addComplition: nil)
                                    .environmentObject(vm)
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    vm.deleteSupplyById(id: supply.id)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                case .categories:
                    List(vm.devices, id: \.self) { device in
                        NavigationLink(destination: SuppliesListForCategoryView(fromOrderView: fromOrderView, category: device, suppliesToCompare: suppliesToCompare, addComplition: addComplition)) {
                            Text(device)
                                .padding()
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Склад")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }.opacity(fromOrderView ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("", selection: $vm.sortOption) {
                        ForEach(vm.sortOptionArray, id: \.self) {
                                        Text($0.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                }
                
            }
            .sheet(isPresented: $showingSheet) {
                AddNewOneView(viewModel: vm, addNewLot: false)
            }
            .task {
                await vm.reload()
            }
            
        }.searchable(text: $searchText)
        
        
    }
    
        var searchResults: [Supply] {
            if searchText.isEmpty {
                return vm.sortedSupplies
            } else {
                return vm.sortedSupplies.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
}

struct SupplyCellView: View {
    let supply: Supply
    let viewForCart: Bool
    let fromOrderView: Bool
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var vm: ViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSheet = false
    @State var addToNote = false
    @State private var countForService = 1
    let addComplition: ((Supply) -> Void)?
    

    var body: some View {
        
        
        HStack {
            
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(supply.name)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    if supply.supplyLot != nil, !supply.supplyLot!.isEmpty {
                        HStack {
                            Text("LOT:")
                                .foregroundColor(Color.secondary)
                            Text(supply.supplyLot ?? "")
                        }.font(.subheadline)
                    }
                }.padding(.bottom, 4)
                    .overlay(Divider(), alignment: .bottom)
                
                Text(supply.device)
                    .font(.footnote)
                    
                HStack {
                    Text("Срок годности:")
                        .foregroundColor(Color.secondary)
                    Text(supply.expiredDate.toString())
                        .foregroundColor(supply.expiredDate > Date() ? .accentColor : .red)
                }.padding(.top, -2)
                .font(.footnote)
                if !viewForCart {
                    HStack {
                        Text("Обновлено:")
                            .foregroundColor(Color.secondary)
                        Text("\(supply.dateCreated.toString())")
                    }
                        .font(.caption2)
                        .padding(.top, -2)
                }
            }
            Spacer()
            
           
            if viewForCart, let cardIndex = cartVM.cart.firstIndex(where: {$0.id == supply.id}) {
                let bindingCount = Binding<Int>(
                    get: {
                        cartVM.cart[cardIndex].count
                    },
                    set: {
                        cartVM.cart[cardIndex].count = $0
                        
                    })
                
                VStack {
                    Text("\(supply.count)")
                        .bold()
                        .opacity(supply.count == 0 ? 0.4 : 1)
                        .padding(.horizontal, 8)
                        .frame(height: 30)
                        .frame(minWidth: 40)
                        .background(colorScheme == .dark ? Color.secondary : Color.white)
                        .cornerRadius(6)
                        .shadow(radius: 2)
                    
                    Stepper("Количество", value: bindingCount, in: 1...(supply.totalCount - (supply.countOnHold ?? 0)))
                        .labelsHidden()
                    
                }.padding(.vertical, 8)
            } else if fromOrderView {
                VStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Button {
                            addToNote = true
                            addComplition?(Supply(id: supply.id,
                                                 name: supply.name,
                                                 device: supply.device,
                                                 count: countForService,
                                                 totalCount: supply.totalCount,
                                                 dateCreated: supply.dateCreated,
                                                 expiredDate: supply.expiredDate,
                                                 countOnHold: supply.countOnHold,
                                                 supplyLot: supply.supplyLot))
                        } label: {
                            Image(systemName: addToNote ? "checkmark.circle" : "plus.circle")
                                .frame(width: 40, height: 30)
                                .background(Color.green)
                                .cornerRadius(6)
                                .shadow(radius: 2)
                        }.buttonStyle(PlainButtonStyle())
                            .disabled(addToNote)
                            .opacity(addToNote ? 0.7 : 1)
                        Text("\(countForService)")
                            .bold()
                            .opacity(supply.totalCount == 0 ? 0.4 : 1)
                            .frame(width: 40, height: 30)
                            .background(colorScheme == .dark ? Color.secondary : Color.white)
                            .cornerRadius(6)
                            .shadow(radius: 2)
                        
                    }
                    if supply.totalCount > 0 {
                        Stepper("Количество", value: $countForService, in: 1...(supply.totalCount - (supply.countOnHold ?? 0)))
                            .labelsHidden()
                            .disabled(addToNote)
                    }
                }.padding(.vertical, 8)
                
            } else {
                
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        if let countOnHold = supply.countOnHold, countOnHold > 0 {
                            Text("\(countOnHold)")
                                .bold()
                                .padding(.horizontal, 8)
                                .frame(height: 30)
                                .frame(minWidth: 40)
                                .background(Color("countOnHold"))
                                .cornerRadius(6)
                                .shadow(radius: 2)
                        }
                        
                        Text("\(supply.totalCount)")
                            .bold()
                            .opacity(supply.totalCount == 0 ? 0.4 : 1)
                            .padding(.horizontal, 8)
                            .frame(height: 30)
                            .frame(minWidth: 40)
                            .background(colorScheme == .dark ? Color.secondary : Color.white)
                            .cornerRadius(6)
                            .shadow(radius: 2)
                            .padding(.trailing, 12)
                        
                    }
                    if !fromOrderView {
                        HStack(spacing: 4) {
                            Button {
                                showingSheet.toggle()
                            } label: {
                                VStack {
                                    Text("new")
                                    Text("LOT")
                                }.foregroundColor(.black)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .frame(height: 30)
                                    .frame(minWidth: 40)
                                    .background(colorScheme == .dark ? Color("backgrndButton") : Color.white)
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                            }.buttonStyle(PlainButtonStyle())
                            
                            Button {
                                cartVM.addSupplyToCart(supply: supply)
                            } label: {
                                Image(systemName: cartVM.cart.contains(where: {$0.id == supply.id}) ? "cart" : "cart.badge.plus")
                                    .foregroundColor(cartVM.cart.contains(where: {$0.id == supply.id}) ? .green : Color.blue)
                                    .frame(width: 40, height: 30, alignment: .center)
                                    .background(colorScheme == .dark ? Color("backgrndButton") : Color.white)
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                                    .padding(.trailing, 12)
                                
                            }.buttonStyle(PlainButtonStyle())
                                .disabled(cartVM.cart.contains(where: {$0.id == supply.id}) || (supply.totalCount - (supply.countOnHold ?? 0)) == 0)
                        }
                        
                    }
                }
                
               
                
                
                
            }
        }
        .sheet(isPresented: $showingSheet) {
            AddNewOneView(viewModel: vm, supply: supply, addNewLot: true)
        }
    }
}
