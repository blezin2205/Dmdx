//
//  ServiceDetailView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 12.01.2022.
//

import SwiftUI

struct ServiceDetailView: View {
    let place: Place
    @StateObject var vm: ServiceDetailViewModel
    @State private var showAddNewServiceNote = false
    
    init(place: Place) {
        self.place = place
        _vm = StateObject.init(wrappedValue: ServiceDetailViewModel(placeId: place.id))
    }
    
    var body: some View {
        ZStack {
            List(vm.serviceNotes) { note in
                //  NavigationLink(destination: OrdersView(place: place)) {
                ServiceDetailCell(note: note)
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                    .listRowSeparator(.hidden)
                // }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(place.name).font(.headline)
                        Text(place.city).font(.subheadline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddNewServiceNote.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }.sheet(isPresented: $showAddNewServiceNote) {
            ServiceNoteAddView(vm: vm, showAddNewServiceNote: $showAddNewServiceNote)
                .onAppear {
                    vm.commentText = ""
                    vm.supplisForNote.removeAll()
                }
        }
    }
}


struct ServiceNoteAddView: View {
    @ObservedObject var vm: ServiceDetailViewModel
    @Binding var showAddNewServiceNote: Bool
    @State private var addNewOne = false
    @State private var isAlertPresenting = false
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 4) {
                    Text("Добавление новой заметки")
                        .font(.system(size: 20))
                        .bold()
                    Divider()
                }.padding(.top, 8)
                
                VStack {
                    VStack {
                        TextEditor(text: $vm.commentText)
                            .frame(height: 250, alignment: .center)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                    }
                    
                    if !vm.supplisForNote.isEmpty {
                        ForEach(vm.supplisForNote) { supp in
                            ServiceNoteSupplyCell(supply: supp, deleteComplition: vm.deleteComplition)
                        }
                    }
                    

                    Spacer()
                    
                    Button("Добавить товар со склада") {
                        addNewOne.toggle()
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Button(action: {
                            vm.addNoteToPlace {
                                showAddNewServiceNote = false
                            }
                        }, label: {
                            Text("Добавить")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(10)
                        })
                        Button(action: {
                            showAddNewServiceNote = false
                        }, label: {
                            Text("Отмена")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .cornerRadius(10)
                        })
                    }.padding(.vertical)
                }
                
            }
            .padding()
        }.sheet(isPresented: $addNewOne) {
            SuppliesListView(fromOrderView: true, suppliesToCompare: vm.supplisForNote) { supply in
                if vm.supplisForNote.contains(supply) {
                    isAlertPresenting = true
                } else {
                    vm.supplisForNote.append(supply)
                    print(vm.supplisForNote)
                }
                
            }
            .alert(isPresented: self.$isAlertPresenting) {
                Alert(title: Text("Ошибка!"), message: Text("Этот товар уже добавлен!"), dismissButton: .default(Text("Ok")))
            }
        }
        
    }

}

struct ServiceNoteSupplyCell: View {
    
    let supply: Supply
    @Environment(\.colorScheme) var colorScheme
    let deleteComplition: (String) -> Void
    
    var body: some View {
        HStack {
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
            }
            Spacer()
                
                HStack {
                    Text("\(supply.count)")
                        .bold()
                        .padding(.horizontal, 8)
                        .frame(height: 30)
                        .frame(minWidth: 40)
                        .background(colorScheme == .dark ? Color.secondary : Color.white)
                        .cornerRadius(6)
                        .shadow(radius: 2)
                    Button {
                        withAnimation(.easeIn) {
                            deleteComplition(supply.id)
                        }
                        
                    } label: {
                        Image(systemName: "trash")
                            .frame(height: 30)
                            .frame(minWidth: 40)
                            .background(colorScheme == .dark ? Color.secondary : Color.white)
                            .cornerRadius(6)
                            .shadow(radius: 2)
                    }
                }.padding(.trailing, 8)
            
           
            }.padding(8)
            
        }.background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

