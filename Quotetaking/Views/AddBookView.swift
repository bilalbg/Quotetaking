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
        
        VStack {
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
    //                image field : bookCover (optional)
                    
                    
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage).onAppear() {
                    if let image = inputImage {
                        if let data = image.pngData() {
                            book.bookCover = Data(base64Encoded: data)
                        }
                    }
                }
            }
            if let img = inputImage {
                Text("Image Chosen")
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
//                    .frame(height: 100)
                    
            }
        }
//        Text(book.title ?? "")
//        Text(book.author ?? "")
//        Text(book.lengthOfBook)
//        Text(book.progress)
        
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    return AddBookView(book: context.firstBook)
}
