//
//  AddNewOneView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 22.11.2021.
//

import SwiftUI
import Firebase
import Combine

struct AddNewOneView: View {
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showingScanningView = false
    var supply: Supply?
    let addNewLot: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var selected = ""
    @State private var date = Date()
    @State private var supplyName = ""
    @State private var count = 1
    @State private var totalCount = 1
    @State private var isSupplyEdit = false
    @State private var elementIsAdded = false
    @State private var supplyLot = ""
    
    var body: some View {
            ScrollView {
                mainView
            }.sheet(isPresented: $showingScanningView) {
                ScanDocumentView(recognizedText: self.$supplyName)
            }
        }
}

extension AddNewOneView {
    private var mainView: some View {
        VStack(spacing: 24) {
            if supply == nil || addNewLot {
                header
            }
            VStack(alignment: .leading, spacing: 24) {
                categoryPicker
                    .padding(.bottom)
                    .disabled(supply != nil && !isSupplyEdit)
                nametextField
                    .disabled(supply != nil && !isSupplyEdit)
                Spacer()
                if addNewLot {
                    lotTextField
                    expirationDatePicker
                    countOfNewOne
                } else {
                    lotTextField
                        .disabled(supply != nil && !isSupplyEdit)
                    expirationDatePicker
                        .disabled(supply != nil && !isSupplyEdit)
                    countOfNewOne
                        .disabled(supply != nil && !isSupplyEdit)
                }
            }
        
            if !addNewLot && supply != nil && supply!.totalCount - (supply!.countOnHold ?? 0) > 0 {
                countAddToCart.opacity(cartViewModel.cart.contains(where: {$0.id == supply!.id}) ? 0 : 1).animation(.linear, value: cartViewModel.cart.contains(where: {$0.id == supply!.id}))
            }
            Spacer()
            addingButton
            
        }.padding()
            .alert(isPresented: self.$viewModel.isAlertPresenting) {
                Alert(title: Text("????????????!"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Ok")))
            }
            .onAppear {
                if let supply = supply {
                    selected = supply.device
                    supplyName = supply.name
                    date = supply.expiredDate
                    count = supply.count
                    totalCount = supply.totalCount
                    supplyLot = supply.supplyLot ?? ""
                } else {
                    selected = viewModel.devices.first ?? ""
                }
            }
            .navigationTitle(supply != nil ? supply!.name : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if isSupplyEdit {
                            let _supply = Supply(id: "",
                                                 name: supplyName,
                                                 device: selected,
                                                 count: count,
                                                 totalCount: totalCount,
                                                 dateCreated: Date(),
                                                 expiredDate: date,
                                                 countOnHold: supply?.countOnHold,
                                                 supplyLot: supplyLot)
                            viewModel.updateElementById(id: supply!.id, newSupply: _supply, oldSupply: supply!)
                        }
                        isSupplyEdit.toggle()
                    } label: {
                        Text(isSupplyEdit ? "??????????????????" : "??????????????????????????")
                    }
                    .opacity(viewModel.buttonDisabled ? 0.3 : 1)
                    .disabled(viewModel.buttonDisabled)
                }
            }
    }
    
    
    
    private var header: some View {
        VStack(spacing: 4) {
            Text(addNewLot ? "???????????????????? ???????????? LOT'a" : "???????????????????? ???????????? ????????????")
                .font(.system(size: 20))
                .bold()
            Divider()
        }
    }
    
    private var addingButton: some View {
        
        ZStack {
            if supply == nil || addNewLot {
                
                Button {
                    let _supply = Supply(id: "",
                                         name: supplyName,
                                         device: selected,
                                         count: count, totalCount: totalCount,
                                         dateCreated: Date(),
                                         expiredDate: date, supplyLot: supplyLot)
                    viewModel.addNewElementToDB(supply: _supply) {
                        elementIsAdded = true
                    }
                } label: {
                    Text(elementIsAdded ? "??????????????????" : "????????????????")
                        .foregroundColor(elementIsAdded ? Color.green : Color.primary)
                        .font(.callout)
                        .bold()
                        .padding()
                        .frame(width: 250, height: 50)
                    
                }
                .background(colorScheme == .dark ? Color.secondary : Color.white)
                .cornerRadius(12)
                .shadow(radius: 3)
                
                .opacity(viewModel.buttonDisabled || elementIsAdded || isSupplyEdit ? 0.4 : 1)
                .disabled(viewModel.buttonDisabled || elementIsAdded || isSupplyEdit)
                
            } else if supply!.totalCount - (supply!.countOnHold ?? 0) > 0 {
                Button {
                    let _supply = Supply(id: supply?.id ?? "",
                                         name: supplyName,
                                         device: selected,
                                         count: count, totalCount: supply?.totalCount ?? totalCount,
                                         dateCreated: Date(),
                                         expiredDate: date,
                                         countOnHold: supply?.countOnHold, supplyLot: supplyLot)
                    cartViewModel.addSupplyToCart(supply: _supply)
                } label: {
                    Text(cartViewModel.cart.contains(where: {$0.id == supply!.id}) ? "?????????????????? ?? ??????????????" : "???????????????? ?? ??????????????")
                        .foregroundColor(cartViewModel.cart.contains(where: {$0.id == supply!.id}) ? Color.green : Color.primary)
                        .font(.callout)
                        .bold()
                        .padding()
                        .frame(width: 250, height: 50)
                }
                .background(colorScheme == .dark ? Color.secondary : Color.white)
                .cornerRadius(12)
                .shadow(radius: 3)
                .disabled(cartViewModel.cart.contains(where: {$0.id == supply!.id}) || isSupplyEdit)
                .opacity(cartViewModel.cart.contains(where: {$0.id == supply!.id}) || isSupplyEdit ? 0.4 : 1)
                
            }
        }
        
        
    }
    
    private var categoryPicker: some View {
        VStack(alignment: .leading) {
            Text("1. ??????????????????")
                .font(.callout)
                .bold()
            Picker("", selection: $selected) {
                ForEach(viewModel.devices, id: \.self) {
                    Text($0)
                }
            }.frame(height: 100)
                .clipped()
                .pickerStyle(.wheel)
        }
    }
    
    private var nametextField: some View {
        
        let binding = Binding<String>(
            get: { supplyName },
            set: {
                supplyName = $0
                viewModel.supplyName = $0
                if elementIsAdded {
                    withAnimation {
                        elementIsAdded = false
                    }
                }
            })
        
        return VStack(alignment: .leading) {
            HStack {
                Text("2. ????????????????")
                    .font(.callout)
                    .bold()
                Spacer()
                Button {
                    showingScanningView.toggle()
                } label: {
                    Image(systemName: "camera.viewfinder")
                }
                
            }
           
            TextField("?????????????? ???????????????? ????????????...", text: binding, onCommit: {
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var lotTextField: some View {
        VStack(alignment: .leading) {
            Text("2. LOT ????????????")
                .font(.callout)
                .bold()
            TextField("?????????????? LOT ????????????(??????????????????????))", text: $supplyLot, onCommit: {
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)
        }
    }
    
    private var expirationDatePicker: some View {
        
        let binding = Binding<Date>(
            get: { date },
            set: {
                date = $0
                if elementIsAdded {
                    withAnimation {
                        elementIsAdded = false
                    }
                }
            })
        return ZStack {
            DatePicker(selection: binding, in: Date().dateForStartExpired()..., displayedComponents: .date) {
                Text("3. ???????? ????????????????")
                    .font(.callout)
                    .bold()
            }
            .environment(\.locale, Locale.init(identifier: "ru"))
        }
    }
    
    private var countOfNewOne: some View {
        VStack(alignment: .leading) {
            Text("4. ???????????????????? ???? ????????????")
                .font(.callout)
                .bold()
            HStack {
                TextField("", value: $totalCount, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
                    .keyboardType(.numberPad)
                Spacer()
                Stepper("????????????????????", value: $totalCount, in: 0...99999)
                    .labelsHidden()
                
            }
        }
    }
    
    private var countAddToCart: some View {
        
        let binding = Binding<Int>(get: {
                    self.count
                }, set: {
                    if $0 > (supply!.totalCount - (supply!.countOnHold ?? 0)) {
                        self.count = supply!.totalCount
                    } else {
                        self.count = $0
                    }
                })
        
       return VStack(alignment: .leading) {
            Text("5. ?? ??????????????")
                .font(.callout)
                .bold()
            HStack {
                TextField("", value: binding, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
                    
                Spacer()
                Stepper("????????????????????", value: binding, in: 1...(supply!.totalCount - (supply!.countOnHold ?? 0)))
                    .labelsHidden()
                
            }
            
            
        }
    }
    
}
