//
//  File.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2025-08-13.
//

import Foundation
import SQLite3
import CoreData

class SQLiteFTSServices: ObservableObject {
    
    private let sqliteManager: SQLiteManager
    
    private func createQuotesTable() {
        let errMSG: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        let sqlStatement = "CREATE TABLE quotes (_id INTEGER PRIMARY KEY, title TEXT, quote TEXT, author TEXT, page INTEGER, notes TEXT);"
        if sqlite3_exec(self.sqliteManager.sqliteDB, sqlStatement, nil, nil, errMSG) == SQLITE_OK {
            print("created table quotes")
        } else {
            print("failed to create q")
        }
    }
    private func createquotesFTSTable() {
        let errMSG: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        let sqlStatement = "CREATE VIRTUAL TABLE IF NOT EXISTS quotesFTS USING FTS4(content='quotes', quote);"
        if sqlite3_exec(self.sqliteManager.sqliteDB, sqlStatement, nil, nil, errMSG) == SQLITE_OK {
            print("created table quotes FTS")
        } else {
            print("failed to create FTS")
        }
    }
    
    private func dropQotSrchFTSTable() {
        let errMSG: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        let sqlStatement = "DROP TABLE IF EXISTS qotsrchFTS;"
        if sqlite3_exec(self.sqliteManager.sqliteDB, sqlStatement, nil, nil, errMSG) == SQLITE_OK {
            print("dropped table")
        }
        let errMSG2: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        let sqlStatement2 = "DROP TABLE IF EXISTS quotesFTS;"
        if sqlite3_exec(self.sqliteManager.sqliteDB, sqlStatement2, nil, nil, errMSG2) == SQLITE_OK {
            print("dropped table 2")
        }
    }
    private func dropQuotesFTSTable() {
        let errMSG: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        let sqlStatement = "DROP TABLE IF EXISTS quotesFTS;"
        if sqlite3_exec(self.sqliteManager.sqliteDB, sqlStatement, nil, nil, errMSG) == SQLITE_OK {
            print("dropped table")
        }
    }
    
    init(sqliteManager: SQLiteManager) {
        self.sqliteManager = sqliteManager
        self.createquotesFTSTable()
        self.createQuotesTable()
    }
    
    func dropTables() {
        dropQotSrchFTSTable()
        dropQuotesFTSTable()
    }
    
    func bulkInsertQuoteTable(quotes: [Quote]) {
        var insertStatement: OpaquePointer? = nil
        var statement = "BEGIN EXCLUSIVE TRANSACTION"
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &insertStatement, nil) != SQLITE_OK {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        statement = "insert into quotes (title, quote, author, page, notes) values (?, ?, ?, ?, ?)"
        var compiledStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &compiledStatement, nil) == SQLITE_OK {
            for quote in quotes {
                let title = quote.title as NSString
                let nsQuote = quote.quote as NSString
                let nsAuthor = quote.author as NSString
                let nsPage = quote.page
                var nsNotes = NSString()
                if let notes = quote.notes {
                    nsNotes = notes as NSString

                }
                sqlite3_bind_text(compiledStatement, 1, title.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(compiledStatement, 2, nsQuote.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(compiledStatement, 3, nsAuthor.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_int(compiledStatement, 4, Int32(nsPage))
                sqlite3_bind_text(compiledStatement, 5, nsNotes.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                while true {
                    let result = sqlite3_step(compiledStatement)
                    if result == SQLITE_DONE {
                        print("DONE")
                        break
                    } else if result != SQLITE_BUSY {
                        print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
                    }
                }
                
                sqlite3_reset(compiledStatement)
            }
        }
        
        statement = "COMMIT TRANSACTION"
        var commitStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &commitStatement, nil) != SQLITE_OK {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(commitStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        sqlite3_finalize(compiledStatement)
        sqlite3_finalize(commitStatement)
        print("FINALIZE")
        insertFromTabletoFTSTable()
    }
    
    func insertFromTabletoFTSTable() {
        var insertStatement: OpaquePointer? = nil
        var statement = "BEGIN EXCLUSIVE TRANSACTION"
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &insertStatement, nil) != SQLITE_OK {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        statement = "INSERT INTO quotesFTS (docid, quote) SELECT _id, quote FROM quotes"
        var compiledStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &compiledStatement, nil) == SQLITE_OK {
            while true {
                let result = sqlite3_step(compiledStatement)
                if result == SQLITE_DONE {
                    print("DONE")
                    break
                } else if result != SQLITE_BUSY {
                    print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
                }
            }
        }
        
        statement = "COMMIT TRANSACTION"
        var commitStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &commitStatement, nil) != SQLITE_OK {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(commitStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        sqlite3_finalize(compiledStatement)
        sqlite3_finalize(commitStatement)
        print("FINALIZE")
    }
    
    func bulkInsertFTSTable(quotes: [Quote]) {
        var insertStatement: OpaquePointer? = nil
        var statement = "BEGIN EXCLUSIVE TRANSACTION"
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &insertStatement, nil) != SQLITE_OK{
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        statement = "insert into quotesFTS (title, quote) values (?, ?)"
        var compiledStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &compiledStatement, nil) == SQLITE_OK {
            for quote in quotes {
                let title = quote.title as NSString
                let nsQuote = quote.quote as NSString
                print(title, nsQuote)
                sqlite3_bind_text(compiledStatement, 1, title.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                sqlite3_bind_text(compiledStatement, 2, nsQuote.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
                while true {
                    let result = sqlite3_step(compiledStatement)
                    if result == SQLITE_DONE {
                        print("DONE")
                        break
                    } else if result != SQLITE_BUSY {
                        print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
                    }
                }
                
                sqlite3_reset(compiledStatement)
            }
        }
        
        statement = "COMMIT TRANSACTION"
        var commitStatement: OpaquePointer? = nil
        print("COMMIT")
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &commitStatement, nil) != SQLITE_OK {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(commitStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        sqlite3_finalize(compiledStatement)
        sqlite3_finalize(commitStatement)
        print("FINALIZE")
    }
    
    func insertQuoteTable(quote: Quote) {
        print(quote)
        var insertStatement: OpaquePointer? = nil
        var statement = "BEGIN EXCLUSIVE TRANSACTION"
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &insertStatement, nil) != 0 {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        statement = "insert into quotes (title, quote, author, page, notes) values (?, ?, ?, ?, ?)"
        var compiledStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &compiledStatement, nil) == SQLITE_OK {
            let title = quote.title as NSString
            let nsQuote = quote.quote as NSString
            let nsAuthor = quote.author as NSString
            let nsPage = quote.page
            let nsNotes = quote.notes! as NSString
            
            sqlite3_bind_text(compiledStatement, 1, title.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(compiledStatement, 2, nsQuote.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(compiledStatement, 3, nsAuthor.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_int(compiledStatement, 4, Int32(nsPage))
            sqlite3_bind_text(compiledStatement, 5, nsNotes.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            while true {
                let result = sqlite3_step(compiledStatement)
                if result == SQLITE_DONE {
                    break
                } else if result != SQLITE_BUSY {
                    print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
                }
            }
            
            sqlite3_reset(compiledStatement)
        }
        
        statement = "COMMIT TRANSACTION"
        var commitStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &commitStatement, nil) != SQLITE_OK {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(commitStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        sqlite3_finalize(compiledStatement)
        sqlite3_finalize(commitStatement)
    }
    
    func insertQuoteFTS(quote: Quote) {
        
        var insertStatement: OpaquePointer? = nil
        var statement = "BEGIN EXCLUSIVE TRANSACTION"
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &insertStatement, nil) != 0 {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        statement = "insert into quotesFTS (title, quote) values (?, ?)"
        var compiledStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &compiledStatement, nil) == SQLITE_OK {
            let title = quote.title as NSString
            let nsQuote = quote.quote as NSString
            
            sqlite3_bind_text(compiledStatement, 1, title.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(compiledStatement, 2, nsQuote.utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            while true {
                let result = sqlite3_step(compiledStatement)
                if result == SQLITE_DONE {
                    break
                } else if result != SQLITE_BUSY {
                    print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
                }
            }
            
            sqlite3_reset(compiledStatement)
        }
        
        statement = "COMMIT TRANSACTION"
        var commitStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, statement, -1, &commitStatement, nil) != 0 {
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        if sqlite3_step(commitStatement) != SQLITE_DONE {
            sqlite3_finalize(insertStatement)
            print("db error: %s\n", sqlite3_errmsg(self.sqliteManager.sqliteDB) ?? "")
            return
        }
        
        sqlite3_finalize(compiledStatement)
        sqlite3_finalize(commitStatement)
    }
    
    
    
    func findAllQuotes(searchBook: String, viewContext: NSManagedObjectContext) -> [Quote] {
        var quotes = [Quote]()
        
        var selectStatement: OpaquePointer? = nil
        let selectSql = "SELECT * FROM quotes WHERE title = '\(searchBook)' ORDER BY page ASC"
        
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, selectSql, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let quote = Quote(context: viewContext)
                quote.title = String(cString: sqlite3_column_text(selectStatement, 0))
                quote.quote = String(cString: sqlite3_column_text(selectStatement, 1))
                quote.author = String(cString: sqlite3_column_text(selectStatement, 2))
                quote.page = Int16(sqlite3_column_int(selectStatement, 3))
                quotes.append(quote)
            }
        }
        
        return quotes
    }
    
    
    func findQuotes(searchBook: String, searchString: String, viewContext: NSManagedObjectContext) -> [Quote] {
        if searchString == "" {
            return self.findAllQuotes(searchBook: searchBook, viewContext: viewContext)
        }
        
        var quotes = [Quote]()
        var selectStatement: OpaquePointer? = nil
        var selectSql: String = ""
        if searchBook != "" {
            selectSql = "SELECT quotesFTS.title, quotesFTS.quote, quotesFTS.author , quotesFTS.page, quotesFTS.notes FROM quotesFTS RIGHT JOIN quotesFTS ON quotesFTS.quote = quotesFTS.quote WHERE quotesFTS.title = '\(searchBook)' AND  quotesFTS.quote LIKE '\(searchString)*' ORDER BY quotesFTS.page ASC"
        } else {
            selectSql = "SELECT quotesFTS.title, quotesFTS.quote, quotesFTS.author, quotesFTS.page, quotesFTS.notes FROM quotesFTS RIGHT JOIN quotesFTS ON quotesFTS.title = quotesFTS.title WHERE quotesFTS.quote MATCH '\(searchString)*' ORDER BY quotesFTS.page ASC"
        }
        selectSql = "SELECT * FROM quotes WHERE _id IN (SELECT docid FROM quotesFTS where quotesFTS MATCH '\(searchString)*') and title = '\(searchBook)' ORDER BY page ASC"
        if sqlite3_prepare_v2(self.sqliteManager.sqliteDB, selectSql, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let quote = Quote(context: viewContext)
                quote.title = String(cString: sqlite3_column_text(selectStatement, 0))
                quote.quote = String(cString: sqlite3_column_text(selectStatement, 1))
                quote.author = String(cString: sqlite3_column_text(selectStatement, 2))
                quote.page = Int16(sqlite3_column_int(selectStatement, 3))
                quotes.append(quote)
            }
        }
        print(quotes.count)
        print("count")
        return quotes
    }
}
