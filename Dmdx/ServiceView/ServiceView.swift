//
//  ServiceView.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 12.01.2022.
//

import SwiftUI

struct ServiceView: View {
    
    @StateObject var vm = ServiceViewModel()
    @State private var showAddNewPlace = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List(vm.places) { place in
                    NavigationLink(destination: ServiceDetailView(place: place)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(place.name)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                            Text(place.city)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                    }
                }
                
                if showAddNewPlace {
                    ZStack {
                        BlankView(isPresented: $showAddNewPlace)
                        VStack {
                            Text("Добавление новой организации")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding()
                            VStack {
                                TextField("Название", text: $vm.name, onCommit: {
                                })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Город", text: $vm.city, onCommit: {
                                })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }.padding(.horizontal)

                            HStack {
                                Button(action: {
                                    vm.addNewPlace {
                                        showAddNewPlace = false
                                    }
                                }, label: {
                                    Text("Добавить")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                })
                                Button(action: {
                                    showAddNewPlace = false
                                }, label: {
                                    Text("Отмена")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                        .background(Color.orange)
                                        .cornerRadius(10)
                                })
                            }.padding(.vertical)
                        }
                            .background(Color.gray)
                            .cornerRadius(16)
                            .padding()
                    }
                    
                }
            }
            .onAppear {
                vm.getPlaces()
            }
            .navigationTitle("Сервисные работы")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddNewPlace.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        
    }
}

struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceView()
    }
}

struct BlankView: View {
    @Binding var isPresented: Bool
    var body: some View {
        VStack {
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black.opacity(0.35))
        .onTapGesture { withAnimation { isPresented = false } }
        .edgesIgnoringSafeArea(.all)
    }
}
