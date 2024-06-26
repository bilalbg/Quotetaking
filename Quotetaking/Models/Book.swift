//
//  Books.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-21.
//

import Foundation
import CoreData
import SwiftUI

final class Book: NSManagedObject, Identifiable {
    
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var progress: Int16
    @NSManaged var length: Int16
    @NSManaged var bookCover: Data?
    @NSManaged var percent: Double
    @NSManaged var quotes: NSSet?
    
    var isValid: Bool {
        !title.isEmpty &&
        !author.isEmpty &&
        !(progress < 0) &&
        !(length <= 0) &&
        progress <= length
    }
    
    public var getQuotesAsArray: [Quote] {
        let set = quotes as? Set<Quote> ?? []
        
        return set.sorted {
            $0.page < $1.page
        }
    }
    
    public func filterQuotes(with config: SearchConfig, order: SortOrder, type: QuoteSortType) -> [Quote] {
        var set = getQuotesAsArray
//        DispatchQueue.main.async {
            if !config.query.isEmpty {
                set = set.filter{ $0.quote.localizedCaseInsensitiveContains(config.query) }
            }
            
            switch type {
            case .quote:
                return (set as NSArray).sortedArray(using: [NSSortDescriptor(keyPath: \Quote.quote, ascending: order == .asc), NSSortDescriptor(keyPath: \Quote.page, ascending: order == .asc)]) as! [Quote]
            case .page:
                return (set as NSArray).sortedArray(using: [NSSortDescriptor(keyPath: \Quote.page, ascending: order == .asc), NSSortDescriptor(keyPath: \Quote.quote, ascending: order == .asc)]) as! [Quote]
            }
//        }
//        return set
    }
    
}

extension Book {
    @objc(addQuoteObject:)
    @NSManaged public func addToQuote(_ value: Quote)
    @objc(removeQuoteObject:)
    @NSManaged public func removeFromQuote(_ value: Quote)
    @objc(addQuote:)
    @NSManaged public func addToQuote(_ values: NSSet)
    @objc(removeQuote:)
    @NSManaged public func removeFromQuote(_ values: NSSet)
    
    
}

extension Book {
    private static var booksFetchRequest: NSFetchRequest<Book> {
        NSFetchRequest(entityName: "Books")
    }
    
    static func all() -> NSFetchRequest<Book> {
        let request: NSFetchRequest<Book> = booksFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Book.title, ascending: true)
        ]
        return request
    }
    
    static func filter(with config: SearchConfig) -> NSPredicate {
        return config.query.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "title CONTAINS[cd] %@", config.query)
        
    }
    
    static func sortType(type: BookSortType, order: SortOrder) -> [NSSortDescriptor] {
        switch type {
        case .title:
            [NSSortDescriptor(keyPath: \Book.title, ascending: order == .asc)]
        case .author:
            [NSSortDescriptor(keyPath: \Book.author, ascending: order == .asc), NSSortDescriptor(keyPath: \Book.title, ascending: true)]
        case .progress:
            [NSSortDescriptor(keyPath: \Book.progress, ascending: order == .asc), NSSortDescriptor(keyPath: \Book.title, ascending: true)]
            
        }
    }
}

//extension Book {
//    public func addToQuotes(_ quote: Quote) {
//        self.quotes.insert(quote)
//    }
//    
//    public func removefromQuotes(_ quote: Quote){
//        self.quotes.remove(quote)
//    }
//    
//    
//}

extension Book {
    
    @discardableResult
    static func makePreview(count: Int, in context: NSManagedObjectContext) -> [Book] {
        var books = [Book]()
        for i in 1..<count+1 {
            let book = Book(context: context)
            book.title = "title \(i)"
            book.author = "author \(i)"
            book.progress = Int16(i*i)
            book.length = Int16(i)*10
            book.percent = Double (book.progress) / Double(book.length)
            book.bookCover = UIImage(systemName: "book.closed.fill")?.withTintColor(.brown).pngData()
            
            books.append(book)
        }
        return books
    }
    
    static func preview(context: NSManagedObjectContext = BooksProvider.shared.viewContext) -> Book {
        return makePreview(count: 1, in: context)[0]
    }
    
    static func empty(context: NSManagedObjectContext = BooksProvider.shared.viewContext) -> Book {
        return Book(context: context)
    }
}
