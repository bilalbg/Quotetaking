//
//  AddBookView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-17.
//

import SwiftUI
import CoreData
import PhotosUI

struct AddBookView: View {
    @State var book: Books
    @State private var inputImage: UIImage?
    
    @State private var showingImagePicker = false
    
    var body: some View {
        //update values to non optional when db is fixed
        
        Form {
            Section(header: Text("Book Info")) {
                
                TextField("Title", text: $book.title ?? "" )
                TextField("Author", text: $book.author ?? "")
                TextField("Length of Book", value: $book.lengthOfBook, format: .number)
                TextField("Progress in book", value: $book.progress , format: .number)
                
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    Text("Tap to select a picture")
                        .foregroundStyle(.white)
                        .font(.headline)
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                //image field : bookCover (optional)
//                ImagePicker(image: $inputImage)
//                if let image = inputImage {
//                    let data = UIImage.pngData(image)
//                    book.bookCover = data
//                }
                
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    return AddBookView(book: context.firstBook)
}
