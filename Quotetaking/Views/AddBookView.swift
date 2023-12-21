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
    @State var book: Book
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        
        VStack {
            Form {
                Section(header: Text("Book Info")) {
                    
                    TextField("Title", text: $book.title)
                    TextField("Author", text: $book.author)
                    TextField("Length of Book", value: $book.length, format: .number)
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
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage).onAppear() {
                    if let image = inputImage {
                        if let data = image.pngData() {
                            book.bookCover = Data(base64Encoded: data)
                            showingImagePicker = false
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
        
    }
}


#Preview {
    let previewProvider = BooksProvider.shared

    return AddBookView(book: .preview(context: previewProvider.viewContext), vm: .init(provider: .shared))
}
