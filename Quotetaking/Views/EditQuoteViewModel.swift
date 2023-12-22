//
//  EditQuoteViewModel.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-21.
//

import SwiftUI
import CoreData

final class EditQuoteViewModel: ObservableObject {
    @Published var quote: Quote
    private let context: NSManagedObjectContext
    private let provider: BooksProvider
    let isNew: Bool
    
    init(provider: BooksProvider, quote: Quote? = nil, title: String = "Title", author: String = "Author") {
      self.context = provider.newViewContext
      self.provider = BooksProvider.shared
      if let quote,
         let existingQuoteCopy = provider.quoteExists(quote, in: context) {
          self.quote = existingQuoteCopy
          self.isNew = false
      } else {
          self.quote = Quote(context: self.context)
          self.isNew = true
      }
        self.quote.title = title
        self.quote.author = author
    }
    
    func save() throws {
        try provider.persist(in: context)
        if context.hasChanges {
            do {
              try context.save()
            } catch {
                
            }
        }
    }
    
}
