//
//  InputView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

// New quote entry view
import SwiftUI

struct AddQuoteView: View {
    var body: some View {
            //update values to non optional when db is fixed
            Form {
                Section(header: Text("Book Info")) {
                    //image field : Image of text (optional)
                    //TextField("Quote", text: $quote ) (optional, this or above required)
                    //TextField("page number", value: $page, format: .number)
                    
                }
            }
    }
}

#Preview {
    AddQuoteView()
}

