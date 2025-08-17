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
    @EnvironmentObject var sqliteFTSServices: SQLiteFTSServices
    
    @FetchRequest(fetchRequest: Quote.all()) private var quotesRequest
    
    @State private var quoteToEdit: Quote?
    @State private var searchConfig: SearchConfig = .init()
    @State private var sortOrder: SortOrder = .asc
    @State private var sortType: QuoteSortType = .page
    @State private var submitted = false
    @State var isSearching = false
    
    @State var historyPagination: Int = 7
    @State var didHistoryPaginationFinishLoading: Bool = false
    @State var paginationIndex: Int = 0
     
    var provider = BooksProvider.shared
    var quotes: FetchedResults<Quote> {
        quotesRequest.nsPredicate = Quote.filter(with: searchConfig, title: book.title)
        quotesRequest.nsSortDescriptors = Quote.sortType(type: sortType, order: sortOrder)
        return quotesRequest
    }
    @State var lastSearch = ""
    
   @State var bookQuotes: [Quote] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            List {
                Text(bookQuotes.count.description + " quotes")
                ForEach(0..<bookQuotes.count, id: \.self) { index in
                    if(index < historyPagination) {
                        NavigationLink(destination: QuoteDetailView(quote: self.bookQuotes[index],
                                                                    vm: .init(provider: provider,
                                                                              quote: self.bookQuotes[index],
                                                                              title: book.title,
                                                                              author: book.author))
                        ) {
                            QuoteView(quote: self.bookQuotes[index])
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu(ContextMenu(menuItems: {
                            Button {
                                do {
                                    try provider.deleteQuote(self.bookQuotes[index], in: provider.newViewContext)
                                } catch {
                                    print(error)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                quoteToEdit = self.bookQuotes[index]
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }))
                    }
                    
                }
                
                LazyVStack {
                    if (historyPagination < bookQuotes.count) {
                        if(!didHistoryPaginationFinishLoading){
                            ProgressView()
                                .onAppear {
                                    // Execute code with delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        historyPagination += 7
                                        didHistoryPaginationFinishLoading = true
                                    }
                                }
                                .onDisappear {
                                    if (historyPagination < bookQuotes.count) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            didHistoryPaginationFinishLoading = false
                                        }
                                    }
                                }
                                .padding(.vertical)
                            
                        }
                    }
                }
            }
            
            .environment(\.defaultMinListRowHeight, 0)
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
                submitted.toggle()
            }, content: { quote in
                NavigationStack {
                    AddQuoteView(vm: .init(provider: provider,
                                           quote: quote,
                                           title: book.title,
                                           author: book.author))
                }
                
            })
        }
        .onChange(of: submitted) {
            DispatchQueue.main.async {
                if book.getQuotesAsArray.count < quotes.count {
                    DispatchQueue.main.async {
                        updateQuotes(quotes, book)
                    }
                }
            }
        }
        .onChange(of: sortOrder) {
            bookQuotes = book.filterQuotes(with: searchConfig, order: sortOrder, type: sortType)
        }
        .onChange(of: sortType) {
            bookQuotes = book.filterQuotes(with: searchConfig, order: sortOrder, type: sortType)
        }
        .onChange(of: searchConfig) {
            searchQuotes(text: searchConfig.query)
        }
//        .onAppear() {
//            bookQuotes = book.filterQuotes(with: searchConfig, order: sortOrder, type: sortType)
//        }
        .onAppear {
            searchQuotes(text: "")
        }
    }
    
    func searchQuotes(text: String) {
        isSearching = true
        let start = Date().timeIntervalSince1970
        DispatchQueue.global(qos: .userInitiated).async {
            bookQuotes = sqliteFTSServices.findQuotes(searchBook: book.title, searchString: text, viewContext: viewContext)
            print(bookQuotes.count)
        }
        print(Date().timeIntervalSince1970 - start)
        
    }
}

private extension BookQuotesView {
    func updateQuotes(_ quotes: FetchedResults<Quote>, _ book: Book) {
        for quote in quotes.filter({$0.book == nil}) {
            if quote.book != book && quote.title == book.title  {
                if quote.title == book.title {
//                        print("pass")
                        quote.book = book
                        viewContext.insert(quote)
//                        print(quote)
                        do {
                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                }
            }
        }
    }
}

//#Preview {
//    let previewProvider = BooksProvider.shared
//    
//    return BookQuotesView(book: .preview(context: previewProvider.viewContext))
//        .onAppear {
//        Quote.makePreview(count: 10, in: previewProvider.viewContext)
//        Book.makePreview(count: 10, in: previewProvider.viewContext)
//    }
//        
//}
