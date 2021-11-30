//
//  Extensions.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 25.11.2021.
//

import Foundation

extension Date {
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter.string(from: self)
    }
    
    func getComponents(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func getComponents(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func dateForStartExpired() -> Date {
        
        let isoDate = "2020-01-01T10:44:00+0000"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from:isoDate)!
    }
}

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func getArrayOfComponentsSeparatedBy(character: String) -> [String] {
        return self.components(separatedBy: character)
    }
}
