//
//  QuotetakingApp.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI

@main
struct QuotetakingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, BooksProvider.shared.viewContext)
        }
    }
}
