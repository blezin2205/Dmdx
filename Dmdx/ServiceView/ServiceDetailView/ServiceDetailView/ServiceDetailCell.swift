//
//  ServiceDetailCell.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 14.01.2022.
//

import SwiftUI

struct ServiceDetailCell: View {
    let note: ServiceModel
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading) {
            Text(note.dateCreated.toString())
                .font(.system(size: 12, weight: .light, design: .default))
                .foregroundColor(.secondary)
                .padding(.bottom, -6)
            Text(note.comment)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(6)
                    .background(RoundedRectangle(cornerRadius: 4).strokeBorder().foregroundColor(.secondary))
                    
            if let supplies = note.supplies {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(supplies, id: \.self) { supp in
                        HStack {
                            Text("☉ \(supp.name)")
                                .font(.footnote)
                                .bold()
                            Spacer()
                            Text(supp.count.description)
                                .bold()
                                .padding(.horizontal, 8)
                                .frame(height: 20)
                                .frame(minWidth: 40)
                                .background(colorScheme == .dark ? Color.secondary : Color.white)
                                .cornerRadius(6)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            
        }
    }
}

struct ServiceDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDetailCell(note: ServiceModel(comment: "Comment Comment Cucc", dateCreated: Date(), supplies: [Supply(id: "", name: "Supply R500 Cartridge", device: "RapidPoint", count: 3, totalCount: 20, dateCreated: Date(), expiredDate: Date()), Supply(id: "", name: "Supply R500 Cartridge", device: "RapidPoint", count: 3, totalCount: 20, dateCreated: Date(), expiredDate: Date())]))
    }
}
