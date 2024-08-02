//
//  GirinApp.swift
//  Girin
//
//  Created by 박찬빈 on 9/30/22.
//

import SwiftUI

@main
struct GirinApp: App {
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
