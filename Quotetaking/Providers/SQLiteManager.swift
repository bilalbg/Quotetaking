
//
//  SQLiteManager.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2025-08-13.
//
import SQLite3
import Foundation

class SQLiteManager: ObservableObject {
    
    var sqliteDB: OpaquePointer? = nil
    private let fileManager: FileManager
    private var dbUrl: URL? = nil
    
    init(fileManager: FileManager) {
        self.fileManager = fileManager
        do {
            let baseUrl = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            print(baseUrl)
            self.dbUrl = baseUrl.appendingPathComponent("swift.sqlite")
        } catch {
            print(error)
        }
        if let dbUrl = self.dbUrl {
            let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
            let status = sqlite3_open_v2(dbUrl.absoluteString.cString(using: String.Encoding.utf8), &sqliteDB, flags, nil)
            
            if status == SQLITE_OK {
                print("status ok")
            }
        }
    }
    
}
