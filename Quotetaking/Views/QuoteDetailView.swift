//
//  QuoteDetailView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI

//page to display a full quote on its own
struct QuoteDetailView: View {
    @ObservedObject var quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.quote)
                .font(.system(size: 18).italic())
            HStack {
                Text(" — \(quote.author) \(quote.page)")
                    .font(.system(size: 16, design: .rounded).bold())
            }
            Text(quote.title)
        }
        .padding()
    }
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return QuoteDetailView(quote: .preview(context: previewProvider.viewContext))
}
