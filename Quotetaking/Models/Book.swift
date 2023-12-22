//
//  Books.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-21.
//

import Foundation
import CoreData

final class Book: NSManagedObject, Identifiable {
    
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var progress: Int16
    @NSManaged var length: Int16
    @NSManaged var bookCover: Data?
    @NSManaged var percent: Double
    
    var isValid: Bool {
        !title.isEmpty &&
        !author.isEmpty &&
        !(progress == 0) &&
        !(length == 0) &&
        progress <= length
    }
    
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
    
    static func sort(order: SortOrder) -> [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \Book.title, ascending: order == .asc)]
    }
    
    static func sortType(type: BookSortType, order: SortOrder) -> [NSSortDescriptor] {
        switch type {
        case .title:
            [NSSortDescriptor(keyPath: \Book.title, ascending: order == .asc)]
        case .author:
            [NSSortDescriptor(keyPath: \Book.author, ascending: order == .asc)]
        case .progress:
            [NSSortDescriptor(keyPath: \Book.progress, ascending: order == .asc)]
            
        }
    }
}

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
