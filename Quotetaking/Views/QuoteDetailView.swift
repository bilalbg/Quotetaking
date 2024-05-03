//
//  QuoteDetailView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI
import ChatGPTSwift

//page to display a full quote on its own
struct QuoteDetailView: View {
    
    let api = ChatGPTAPI(apiKey: Bundle.main.infoDictionary?["API_KEY"]  as? String ?? "not found")
    @State private var explanation: String?
    @State private var explanationReceived: Bool = false
    
    @ObservedObject var quote: Quote
    @ObservedObject var vm: EditQuoteViewModel
    
    @State private var scrollViewContentSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits {
                Text(quote.quote)
                    .font(.system(size: 18).italic())
                ScrollView {
                    Text(quote.quote)
                        .font(.system(size: 18).italic())
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        Task { @MainActor in
                                            scrollViewContentSize = geo.size
                                        }
                                    }
                            }
                        )
                }
                .frame(maxHeight: scrollViewContentSize.height > 200 ? 300 : 150)
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            }

                
            HStack {
                Text(" — \(quote.author), \(quote.page)")
                    .font(.system(size: 16, design: .rounded).bold())
            }
            Text(quote.title)
        }
        .padding()
        Section {
            HStack {
                ShareLink("Share Quote", item: quoteToFormat(quote))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
                Button(action: {
                    getExplanation(quote.quote, quote.author, quote.title)
                }) {
                    Text("AI Explanation")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle( BorderlessButtonStyle())
                .disabled(vm.quote.explanation != nil)
            }
            .padding()
            VStack{
                if let AiExplanation = vm.quote.explanation {
                    ScrollView {
                        Text(AiExplanation)
                            .font(.system(size: 12).italic())
                            .padding()
                    }
                    .frame(maxHeight: 250)
                    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                }
            }
        }
        .onChange(of: explanationReceived) {
            print(explanationReceived)
            explanationReceived.toggle()
            print("Toggle")
            updateQuote()
            
        }
    }
}

private extension QuoteDetailView {
    func quoteToFormat(_ quote: Quote) -> String {
        return "\"\(quote.quote)\", \(quote.author) \(quote.page), \(quote.title)"
    }
    func getExplanation(_ quote: String, _ author: String, _ title: String)  {
        let prompt = "Explain this quote \"\(quote)\" by \(author) from \(title). Reply N/A if you don't know the book or context."
        Task {
            do {
                let response = try await api.sendMessage(text: prompt)
                vm.quote.explanation = response
                explanationReceived.toggle()
            } catch {
                print(error)
            }
        }
    }
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
