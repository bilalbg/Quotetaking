//
//  QuotetakingApp.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI

@main
struct QuotetakingApp: App {
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
      }
    }
    var body: some Scene {
        @StateObject var sqliteManager = SQLiteManager(fileManager: FileManager.default)
        @StateObject var sqLiteFTSServices = SQLiteFTSServices(sqliteManager: sqliteManager)
        
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, BooksProvider.shared.viewContext)
                .environmentObject(sqLiteFTSServices)
        }
    }
}
