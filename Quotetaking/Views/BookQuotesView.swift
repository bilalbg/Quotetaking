//
//  BookQuotesView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI
import CoreData

struct BookQuotesView: View {
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
        VStack(alignment: .leading, spacing: 8) {
            List {
                ForEach(quotes) { quote in
                    NavigationLink(destination: QuoteDetailView(quote: quote)) {
                        QuoteView(quote: quote)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu(ContextMenu(menuItems: {
                        Button("Delete") {
                            do {
                                try provider.deleteQuote(quote, in: provider.newViewContext)
                            } catch {
                                print(error)
                            }
                        }
                        Button("Edit") {
                            quoteToEdit = quote
                        }
                    }))
                }
                .onAppear {
                    quotes.nsPredicate = Quote.filter(with: searchConfig, title: book.title)
                }
            }
            .searchable(text: $searchConfig.query)
            .navigationTitle("Quotes for \(book.title)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        quoteToEdit = .empty(context: provider.newViewContext)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Text("Sort")
                        Section {
                            Picker(selection: $sortType) {
                                Text("Quote").tag(QuoteSortType.quote)
                                Text("Page").tag(QuoteSortType.page)
                            } label : {
                                Text("Sort By")
                            }
                        }
                        Section {
                            Picker(selection: $sortOrder) {
                                Label("Asc", systemImage: "arrow.up").tag(SortOrder.asc)
                                Label("Desc", systemImage: "arrow.down").tag(SortOrder.desc)
                            } label : {
                                Text("Sort Order")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .symbolVariant(.circle)
                            .font(.title2)
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
            .onChange(of: sortOrder) {
                quotes.nsSortDescriptors = Quote.sortType(type: sortType, order: sortOrder)
            }
            .onChange(of: sortType) {
                quotes.nsSortDescriptors = Quote.sortType(type: sortType, order: sortOrder)
            }
            .onChange(of: searchConfig) {
                quotes.nsPredicate = Quote.filter(with: searchConfig, title: book.title)
            }
            .onAppear {
                quotes.nsSortDescriptors = Quote.sortType(type: sortType, order: sortOrder)
        }
        }
    }
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return BookQuotesView(book: .preview(context: previewProvider.viewContext))
        .onAppear {
        Quote.makePreview(count: 10, in: previewProvider.viewContext)
        Book.makePreview(count: 10, in: previewProvider.viewContext)
    }
        
}
