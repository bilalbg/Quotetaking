//
//  AddBookView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI

struct AddBookView: View {
    
    var body: some View {
        //update values to non optional when db is fixed
        Form {
            Section(header: Text("Book Info")) {
                //TextField("Title", text: $title )
                //TextField("Author", text: $author)
                //TextFiel("Length of Book", value: $length, format: .number)
                //TextField("Progress in book", value: $progress, format: .number)
                //image field : bookCover (optional) 
            }
        }
    }
}

#Preview {
    return AddBookView()
}

