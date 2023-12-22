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
    
    @FetchRequest(fetchRequest: Book.all()) private var books
    
    @State private var bookToEdit: Book?
    @State private var searchConfig: SearchConfig = .init()
    @State private var sortOrder: SortOrder = .asc
    @State private var sortType: BookSortType = .title
    @State private var isActive = false
    
    var provider = BooksProvider.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !books.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:125))], spacing: 5) {
                        ForEach(books) { book in
                            NavigationLink(destination: QuotesView(book: book)) {
                                BookView(book: book)
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                Button("Delete") {
                                    do {
                                        try provider.deleteBook(book, in: provider.newViewContext)
                                    } catch {
                                        print(error)
                                    }
                                }
                                Button("Edit") {
                                    bookToEdit = book
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
                books.nsPredicate = Book.filter(with: searchConfig)
            }
            .onChange(of: sortOrder) {
                books.nsSortDescriptors = Book.sort(order: sortOrder)
            }
            .onChange(of: sortType) {
                books.nsSortDescriptors = Book.sortType(type: sortType, order: sortOrder)
            }
        }
    }
}



#Preview {
    let preview = BooksProvider.shared
    return ContentView(provider: preview)
        .environment(\.managedObjectContext, preview.viewContext)
        .previewDisplayName("Books with Data")
        .onAppear {
            Book.makePreview(count: 10, in: preview.viewContext)
        }
    
//    let emptyPreview = BooksProvider.shared
//    return ContentView(provider: emptyPreview)
//        .environment(\.managedObjectContext, preview.viewContext)
//        .previewDisplayName("Books with Data")
}
