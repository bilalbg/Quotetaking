//
//  BookView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI
import CoreData

struct BookView: View {
    @ObservedObject var book: Book
    
    var body: some View {
        
        VStack {
            if let img = getImage(data: book.bookCover) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            }
            else {
                Text("No Image data")
            }
            Text(book.title)
            Text("By: \(book.author)")
                
            ProgressView(value: book.percent, total: 1.0)
        }
    }
}

func getImage(data: Data?) -> UIImage? {
    
    guard let imgData = data else {return nil}
    guard let img = UIImage(data: imgData) else {return nil}
    
    return img
}

#Preview {
    let previewProvider = BooksProvider.shared
    
    return BookView(book: .preview(context: previewProvider.viewContext))
}
