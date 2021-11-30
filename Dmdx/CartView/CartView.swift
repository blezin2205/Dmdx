//
//  CartView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 25.11.2021.
//

import SwiftUI

struct CartView: View {
    @State private var showingSheet = false
    @ObservedObject var cartVM: CartViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            ZStack {
                if cartVM.cart.isEmpty {
                    VStack {
                        Image("emptyCart")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 200, height: 200, alignment: .center)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .animation(.interactiveSpring(), value: cartVM.cart.isEmpty)
                    }
                } else {
                    
                    List {
                        Section(header: Text("ID заказа: \(cartVM.idForOrder)")) {
                            ForEach(cartVM.cart) { supply in
                               
                                SupplyCellView(supply: supply, viewForCart: true)
                                    .swipeActions(allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            if let index = cartVM.cart.firstIndex(where: {$0.id == supply.id}) {
                                                cartVM.cart.remove(at: index)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                
                            }
                            
                            
                            
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                        .overlay(
                            Text("\(cartVM.cartCountSupply)")
                                .bold()
                                .frame(width: 50, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(.blue)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                                .padding(16)
                            , alignment: .bottomTrailing
                        )
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Корзина")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        cartVM.deleteCart()
                    } label: {
                        Image(systemName: "trash")
                    }.disabled(cartVM.cart.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        //cartVM.updateDBforCart()
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "paperplane")
                    }.disabled(cartVM.cart.isEmpty)
                }
            }
    }
        .sheet(isPresented: $showingSheet) {
            ChoosePlaceView(cartVM: cartVM)
    }
    }
}

//struct CartView_Previews: PreviewProvider {
//    static var previews: some View {
//        CartView()
//    }
//}

struct ChoosePlaceView: View {
    
    @ObservedObject var cartVM: CartViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                HStack {
                    Text("Выберите организацию")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                    Button("Ок") {
                        cartVM.updateDBforCart() {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }.opacity(cartVM.selectedPlace == nil ? 0.3 : 1)
                        .disabled(cartVM.selectedPlace == nil)
                }
            }.padding()
            Divider()
            List(cartVM.places, id: \.self, selection: $cartVM.selectedPlace) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    Text(place.city)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                }
                
            }
        }
        .environment(\.editMode, .constant(EditMode.active))
    }
}
