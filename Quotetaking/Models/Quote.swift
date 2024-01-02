//
//  Quote.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-21.
//


import Foundation
import CoreData

final class Quote: NSManagedObject, Identifiable {
    
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var quote: String
    @NSManaged var page: Int16
    
    var isValid: Bool {
        !title.isEmpty &&
        !author.isEmpty &&
        !quote.isEmpty &&
        !(page <= 0)
    }
    
}


extension Quote {
    private static var quotesFetchRequest: NSFetchRequest<Quote> {
        NSFetchRequest(entityName: "Quotes")
    }
    
    static func all() -> NSFetchRequest<Quote> {
        let request: NSFetchRequest<Quote> = quotesFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Quote.quote, ascending: true)
        ]
        return request
    }
    
    static func filter(with config: SearchConfig, title: String) -> NSPredicate {
        return config.query.isEmpty ? NSPredicate(format: "title contains [cd] %@", title) : NSPredicate(format: "title contains [cd] %@ AND quote CONTAINS[cd] %@",title, config.query)
        
    }
    
    static func sortType(type: QuoteSortType, order: SortOrder) -> [NSSortDescriptor] {
        switch type {
        case .quote:
            [NSSortDescriptor(keyPath: \Quote.quote, ascending: order == .asc)]
        case .page:
            [NSSortDescriptor(keyPath: \Quote.page, ascending: order == .asc), NSSortDescriptor(keyPath: \Quote.quote, ascending: true)]
            
        }
    }
}

extension Quote {
    
    @discardableResult
    static func makePreview(count: Int, in context: NSManagedObjectContext) -> [Quote] {
        var quotes = [Quote]()
        for i in 1..<count+1 {
            let quote = Quote(context: context)
            quote.title = "title \(i)"
            quote.author = "author \(i)"
            quote.quote = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec metus imperdiet, ullamcorper nisi dapibus, volutpat lectus. Maecenas justo felis, suscipit id semper sed, suscipit eget justo. Vestibulum neque diam, rutrum et nunc vestibulum, auctor congue neque. Duis dictum libero at sodales luctus. Ut eget ipsum pretium, efficitur tortor non, fermentum tellus. Phasellus efficitur magna nec libero feugiat consequat. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis volutpat elit turpis, sit amet ultricies ante venenatis id. Sed nec est quis orci molestie eleifend vel eu lacus. Duis dapibus odio ac felis placerat pretium. Quisque sodales, metus et semper ornare, justo mauris commodo lorem, vitae tincidunt odio ex sed diam."
            quote.page = Int16(i*i)
            
            quotes.append(quote)
        }
        return quotes
    }
    
    static func preview(context: NSManagedObjectContext = BooksProvider.shared.viewContext) -> Quote {
        return makePreview(count: 1, in: context)[0]
    }
    
    static func empty(context: NSManagedObjectContext = BooksProvider.shared.viewContext) -> Quote {
        return Quote(context: context)
    }
}
