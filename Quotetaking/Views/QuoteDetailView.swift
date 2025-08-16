//
//  QuoteDetailView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI
//import ChatGPTSwift

//page to display a full quote on its own
struct QuoteDetailView: View {
    
    struct BookInfo: Equatable {
        var title: String = ""
        var author: String = ""
    }
    
//    let api = ChatGPTAPI(apiKey: Bundle.main.infoDictionary?["API_KEY"]  as? String ?? "not found")
    
    @State private var quoteToEdit: Quote?
    @State private var explanation: String?
    @State private var explanationReceived: Bool = false
//    @State private var book: Book?
    
    @ObservedObject var quote: Quote
    @ObservedObject var vm: EditQuoteViewModel
    
//    @State private var scrollViewContentSize: CGSize = .zero
    
    var provider = BooksProvider.shared
    var bookInfo: BookInfo {
        return BookInfo.init(title: quote.title, author: quote.author)
    }
    
    var body: some View {
        TabView {
                VStack(alignment: .leading, spacing: 8) {
                    ViewThatFits {
                        Text(quote.quote)
                            .font(.system(size: 18).italic())
                    }

                        
                    HStack {
                        Text(" — \(bookInfo.author), \(quote.page)")
                            .font(.system(size: 16, design: .rounded).bold())
                    }
                    
                    Text(bookInfo.title)
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width)
                
                VStack{
                    Text(vm.quote.explanation ?? "Use the AI Explanation button to get an explanation and more context on the quote here")
                    .font(.system(size: 12).italic())
                    .padding()
                    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                }
                .frame(width: UIScreen.main.bounds.width)
            VStack {
                Text(quote.notes != nil && !quote.notes!.isEmpty ? quote.notes! : "Add Notes to see them here")
                    .font(.system(size: 12).italic())
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    quoteToEdit = vm.quote
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(item: $quoteToEdit, onDismiss: {
            quoteToEdit = nil
        }, content: { quote in
            NavigationStack {
                AddQuoteView(vm: .init(provider: provider,
                                       quote: quote,
                                       title: bookInfo.title,
                                       author: bookInfo.author))
            }
            
        })
        
        Section {
            HStack {
                ShareLink("Share Quote", item: quoteToFormat(quote))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
//                Button(action: {
//                    getExplanation(quote.quote, quote.author, quote.title)
//                }) {
//                    Text("AI Explanation")
//                        .frame(maxWidth: .infinity)
//                }
//                .buttonStyle( BorderlessButtonStyle())
//                .disabled(vm.quote.explanation != nil)
            }
            .padding()
        }
        .onChange(of: explanationReceived) {
            print(explanationReceived)
            print("Toggle")
            updateQuote()
            
        }
    }
}

private extension QuoteDetailView {
    func quoteToFormat(_ quote: Quote) -> String {
        return "\"\(quote.quote)\", \(quote.author) \(quote.page), \(quote.title)"
    }
//    func getExplanation(_ quote: String, _ author: String, _ title: String)  {
//        let prompt = "Explain this quote \"\(quote)\" by \(author) from \(title). Reply N/A if you don't know the book or context."
//        Task {
//            do {
//                let response = try await api.sendMessage(text: prompt)
//                vm.quote.explanation = response
//                explanationReceived.toggle()
//            } catch {
//                print(error)
//            }
//        }
//    }
    func updateQuote() {
        if vm.quote.isValid {
            do {
                try vm.save()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return QuoteDetailView(quote: .preview(context:                                 previewProvider.viewContext),
                           vm: .init(provider: previewProvider))
}
