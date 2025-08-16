//
//  QuotetakingApp.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI

@main
struct QuotetakingApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        var sqliteFTSServices = SQLiteFTSServices(sqliteManager: SQLiteManager(fileManager: FileManager.default))

        return true
      }
    }
    var body: some Scene {
//        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        @StateObject var sqliteManager = SQLiteManager(fileManager: FileManager.default)
        @StateObject var sqLiteFTSServices = SQLiteFTSServices(sqliteManager: sqliteManager)
        
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, BooksProvider.shared.viewContext)
//                .environmentObject(sqliteManager)
                .environmentObject(sqLiteFTSServices)
        }
    }
}
