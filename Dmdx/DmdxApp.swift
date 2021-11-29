//
//  DmdxApp.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 20.11.2021.
//

import SwiftUI
import Firebase

@main
struct DmdxApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
