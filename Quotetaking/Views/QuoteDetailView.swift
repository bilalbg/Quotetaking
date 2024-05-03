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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.quote)
                .font(.system(size: 18).italic())
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
                    print("Button pressed")
                    getExplanation(quote.quote, quote.author, quote.title)
//                    if apiResponse != "N/A" {
//                        explanation = apiResponse
//                    }
//                    else {
//                        print("Nothing")
//                    }
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
                    Text(AiExplanation)
                        .font(.system(size: 12).italic())
                        .padding()
                }
            }
        }
        .onChange(of: explanationReceived) {
            explanationReceived.toggle()
            print("updated")
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
//        var response = "N/A"
//        print(api.self)
        Task {
            do {
                let response = try await api.sendMessage(text: prompt)
//                print(response)
                vm.quote.explanation = response
                print("space \n")
                print(vm.quote.explanation)
                explanationReceived.toggle()
            } catch {
                print(error)
            }
        }
//        print(response + "\n in task")
//        return response
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
