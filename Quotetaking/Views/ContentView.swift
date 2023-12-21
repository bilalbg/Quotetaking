//
//  ContentView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI
import CoreData

struct SearchConfig: Equatable {
    
    enum Filter {
        case all
    }
    
    var query: String = ""
    var filter: Filter = .all
    
}
enum Sort {
    case asc, desc
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: Book.all()) private var books
    //    @FetchRequest(
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Books.title, ascending: true)],
    //        animation: .default)
    
    //probably need to change this so it updates properly and doesn't multiply the list like it is now when adding items
    //    private var books: FetchedResults<Books>
    
    //    @State private var newItem: Books
    
    //    @State private var isPresentingAddView = false
    //    private var didSave = NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    @State private var bookToEdit: Book?
    @State private var searchConfig: SearchConfig = .init()
    @State private var sort: Sort = .asc
    
    var provider = BooksProvider.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !books.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum:125))], spacing: 5) {
                        ForEach(books) { book in
                            NavigationLink(destination: BookQuotesView()) {
                                BookView(book: book)
                            }
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
                        Section {
                            Text("Filter")
                        }
                        Section {
                            Text("Sort")
                            Picker(selection: $sort) {
                                Label("Asc", systemImage: "arrow.up").tag(Sort.asc)
                                Label("Desc", systemImage: "arrow.down").tag(Sort.desc)
                            } label : {
                                Text("Sort By")
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
            }, content: {book in
                NavigationStack {
                    AddBookView(book: book,
                                vm: .init(provider: provider))
                }
            })
            .navigationTitle("Your books")
        }
    }
}


//    private func addItem() {
//        withAnimation {
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { books[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

//extension NSManagedObjectContext {
//    var firstBook: Books {
//        let fetchRequest = Books.fetchRequest()
//        fetchRequest.fetchLimit = 1
//        let result = try! fetch(fetchRequest)
//        return result.first!
//    }
//}

