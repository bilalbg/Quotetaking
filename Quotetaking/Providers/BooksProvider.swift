//
//  BooksProvider.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-20.
//

import Foundation
import CoreData
import SwiftUI


struct BooksProvider {
    static let shared = BooksProvider()
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var newViewContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Quotetaking")
        if EnvironmentValues.isPreview || Thread.current.isRunningXCTest {
            persistentContainer.persistentStoreDescriptions.first?.url = .init(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
        
    }
    
    
    
    func bookExists(_ book: Book,
                in context: NSManagedObjectContext) -> Book? {
        try? context.existingObject(with: book.objectID) as? Book
    }
    func deleteBook(_ book: Book,
                in context: NSManagedObjectContext) throws{
        if let existingBook = bookExists(book, in: context) {
            context.delete(existingBook)
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }
    
    func quoteExists(_ quote: Quote,
                in context: NSManagedObjectContext) -> Quote? {
        try? context.existingObject(with: quote.objectID) as? Quote
    }
    func deleteQuote(_ quote: Quote,
                in context: NSManagedObjectContext) throws{
        if let existingQuote = quoteExists(quote, in: context) {
            context.delete(existingQuote)
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }
    
    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

extension EnvironmentValues {
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

extension Thread {
    var isRunningXCTest: Bool {
        for key in self.threadDictionary.allKeys {
            guard let keyAsString = key as? String else {
                continue
            }
            
            if keyAsString.split(separator: ".").contains("xctest") {
                return true
            }
        }
        return false
    }
}
