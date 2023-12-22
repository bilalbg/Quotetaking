//
//  EditBookView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-20.
//

import SwiftUI
import CoreData

final class EditBookViewModel: ObservableObject {
    @Published var book: Book
    private let context: NSManagedObjectContext
    private let provider: BooksProvider
    let isNew: Bool
    
    init(provider: BooksProvider, book: Book? = nil) {
      self.context = provider.newViewContext
      self.provider = BooksProvider.shared
      if let book,
         let existingBookCopy = provider.exists(book, in: context) {
          self.book = existingBookCopy
          self.isNew = false
      } else {
          self.book = Book(context: self.context)
          self.isNew = true
      }
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
