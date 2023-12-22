//
//  BookQuotesView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI
import CoreData

struct QuotesView: View {
    let book: Book
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: Quote.all()) private var quotes
    
    @State private var quoteToEdit: Quote?
    @State private var searchConfig: SearchConfig = .init()
    @State private var sortOrder: SortOrder = .asc
    @State private var sortType: QuoteSortType = .page
    @State private var isActive = false
    
    var provider = BooksProvider.shared
    
    var body: some View {
        VStack {
            ForEach(quotes) { quote in
                NavigationLink(destination: QuoteDetailView(quote: quote)) {
                    QuoteView(quote: quote)
                    Text(quote.title)
                }
            }
            .onAppear {
                quotes.nsPredicate = Quote.filter(with: searchConfig, title: book.title)
            }
            //have an edit button in toolbar to edit book info
        }
        .navigationTitle("Quotes for \(book.title)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    quoteToEdit = .empty(context: provider.newViewContext)
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(item: $quoteToEdit, onDismiss: {
            quoteToEdit = nil
        }, content: { quote in
            NavigationStack {
                AddQuoteView(vm: .init(provider: provider,
                                       quote: quote,
                                       title: book.title,
                                       author: book.author))
            }
        })
    }
}
func tmp(quote: Quote) {
    print(quote)
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return QuotesView(book: .preview(context: previewProvider.viewContext))
        .onAppear {
            Quote.makePreview(count: 10, in: previewProvider.viewContext)
            Book.makePreview(count: 10, in: previewProvider.viewContext)
        }
}
