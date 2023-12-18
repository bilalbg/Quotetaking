//
//  BookView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI
import CoreData

struct BookView: View {
    @ObservedObject var book: Books
    
    var body: some View {
        
        if let bookName = book.title {
            Text(bookName)
//            Text(book.progress)
//            Text(book.author)
//            Text(book.lengthOfBook)
//            Image(book.bookCover)
            
        } /*else {
            Text("No book here")
        }*/
        // ^ for ui visibility until I add book objects

    }
}


#Preview {
    
    let context = PersistenceController.preview.container.viewContext

    
    return BookView(book: context.firstBook)
}

extension NSManagedObjectContext {
    var firstBook: Books {
        let fetchRequest = Books.fetchRequest()
        fetchRequest.fetchLimit = 1
        let result = try! fetch(fetchRequest)
        return result.first!
    }
}
