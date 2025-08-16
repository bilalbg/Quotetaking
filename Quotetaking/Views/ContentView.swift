//
//  ContentView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI
import CoreData



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sqliteFTSServices: SQLiteFTSServices
    
    @FetchRequest(fetchRequest: Book.all()) private var books
    
    @State private var bookToEdit: Book?
    @State private var searchConfig: SearchConfig = .init()
    @State private var sortOrder: SortOrder = .asc
    @State private var showFilePicker = false
    @State private var sortType: BookSortType = .title
    @State private var isActive = false
    @State private var doc: Document?
//    @State private var docPicker = DocumentPickerViewController()
    
    var provider = BooksProvider.shared
//    private var sqliteFTSServices = SQLiteFTSServices(sqliteManager: sqliteManager)
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !books.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:100))], spacing: 5) {
                        ForEach(books) { book in
                            NavigationLink(destination: BookQuotesView(book: book/*, quotesVM: QuoteViewModel(quotes: book.getQuotesAsArray)*/)) {
                                BookView(book: book)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu(ContextMenu(menuItems: {
                                Button {
                                    do {
                                        try provider.deleteBook(book, in: provider.newViewContext)
                                    } catch {
                                        print(error)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    bookToEdit = book
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }))
                           
                        }
                    }
                    
                }
                
            }
            .searchable(text: $searchConfig.query)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        bookToEdit = .empty(context: provider.newViewContext)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Text("Sort")
                        Section {
                            Picker(selection: $sortType) {
                                Text("Title").tag(BookSortType.title)
                                Text("Author").tag(BookSortType.author)
                                Text("Progress").tag(BookSortType.progress)
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
            .sheet(item: $bookToEdit, onDismiss: {
                bookToEdit = nil
            }, content: { book in
                NavigationStack {
                    AddBookView(vm: .init(provider: provider,
                                          book: book))
                }
            })
            .navigationTitle("Your books")
            .onChange(of: searchConfig) {
//                books.nsPredicate = NSPredicate(format: <#T##String#>)
                books.nsPredicate = Book.filter(with: searchConfig)
            }
            .onChange(of: sortOrder) {
                books.nsSortDescriptors = Book.sortType(type: sortType, order: sortOrder)
            }
            .onChange(of: sortType) {
                books.nsSortDescriptors = Book.sortType(type: sortType, order: sortOrder)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .onAppear {
            books.nsSortDescriptors = Book.sortType(type: sortType, order: sortOrder)
        }
        .sheet(isPresented: $showFilePicker) {
//            Text("")
            
            docPicker(doc: $doc)
        }
        
        
            Button {
                dropTables()
                
            } label: {
                Label("Drop sqlite tables", systemImage: "plus")
            }
            Button {
                insertToSqlite()
                
            } label: {
                Label("Insert into sqlite", systemImage: "plus")
            }
            Button {
                provider.exportData()
                
            } label: {
                Label("Export", systemImage: "plus")
            }
            Button {
                
                showFilePicker.toggle()
                
            } label: {
                Label("Import", systemImage: "plus")
            }
//                            Label("Export")
//                                .onTapGesture {
//                                    provider.exportData()
//                                }
//                            Label("Import")
    }
    func dropTables() {
        DispatchQueue.global().async {
            self.sqliteFTSServices.dropTables()
        }
    }
    
    func insertToSqlite() {
//        var res: Bool = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            let bookList = books
//            res = true
            for book in bookList {
                if let quotes = book.quotes {
                    let quoteList = quotes.allObjects as! [Quote]
//                    print(book.title)
                    DispatchQueue.main.async {
                        sqliteFTSServices.bulkInsertFTSTable(quotes: quoteList)
                    }
                    DispatchQueue.main.async {
                        sqliteFTSServices.bulkInsertQuoteTable(quotes: quoteList)
                    }
                }
            }
        }
    }
}





#Preview {
    let preview = BooksProvider.shared
    ContentView()
        .environment(\.managedObjectContext, preview.viewContext)
//        .previewDisplayName("Books with Data")
        .onAppear {
            Book.makePreview(count: 10, in: preview.viewContext)
        }
}
