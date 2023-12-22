//
//  QuoteDetailView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI

struct QuoteDetailView: View {
    @ObservedObject var quote: Quote
    
    var body: some View {
        VStack {
            Text(quote.title)
            Text("By: \(quote.author)")
            Text(quote.quote)
            Text(String(quote.page))
        }
    }
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return QuoteDetailView(quote: .preview(context: previewProvider.viewContext))
}
