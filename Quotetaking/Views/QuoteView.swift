//
//  QuoteView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-22.
//

import SwiftUI
import Foundation

struct QuoteView: View {
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
    
    return QuoteView(quote: .preview(context: previewProvider.viewContext))
}
