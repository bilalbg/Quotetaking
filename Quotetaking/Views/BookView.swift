//
//  BookView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

import SwiftUI
import CoreData

struct BookView: View {
    @ObservedObject var book: Books
    
    var body: some View {
        
        VStack {
            if let bookName = book.title {
                if let imgData = book.bookCover {
                    if let img = UIImage(data: imgData) {
                        Text("Image converted")
                        Image(uiImage: img)
                            .resizable()
                    }
                    else {
                        Text("No Image")
                    }
                }
                else {
                    Text("No Image data")
                }
                Text(bookName)
                Text("By: " + (book.author ?? "Unknown"))
                
                ProgressView(value: getProgress(progress: Double(book.progress), length: Double(book.lengthOfBook)), total: 1.0)
                
            }
            else {
              Text("No book here")
            }
            
            // ^ for ui visibility until I add book objects
        }
    }
}

func getProgress(progress: Double, length: Double) -> Double {
    return progress / length
}


#Preview {
    
    let context = PersistenceController.preview.container.viewContext

    
    return BookView(book: context.firstBook)
}
