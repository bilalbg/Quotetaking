//
//  QuoteView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-22.
//

import SwiftUI
import Foundation

//quote objects for the quotes list
struct QuoteView: View {
    @ObservedObject var quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.quote)
                .font(.system(size: 12).italic())
                .lineLimit(4)
            HStack {
                Text(" — \(quote.author) \(quote.page)")
                    .font(.system(size: 16, design: .rounded).bold())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading )
        .padding()
        
    }
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return QuoteView(quote: .preview(context: previewProvider.viewContext))
}
