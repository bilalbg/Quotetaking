//
//  BookQuotesView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI

struct BookQuotesView: View {
    let book: Book
    
    var body: some View {
        Text(book.title)
        Text(book.author)
        Text(String(book.progress))
        Text(String(book.length))
        Text(String(book.percent))
        //have an edit button in toolbar to edit book info
    }
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return BookQuotesView(book: .preview(context: previewProvider.viewContext))
}
