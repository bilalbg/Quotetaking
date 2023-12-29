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
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraController = false
    @State private var hasError: Bool = false
    
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        
        VStack {
            List {
                Section("Book Info") {
                    
                    TextField("Title", text: $vm.book.title)
                    TextField("Author", text: $vm.book.author)
                    TextField("Progress in book", value: $vm.book.progress , format: .number)
                        .keyboardType(.phonePad)
                    TextField("Length of Book", value: $vm.book.length, format: .number)
                        .keyboardType(.phonePad)
                }
                Section("Upload a book cover") {
                    HStack {
                        Button(action: {
                            self.showingCameraController.toggle()
                        }) {
                            Text("Camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle( BorderlessButtonStyle())
                        
                        Button(action: {
                            self.showingImagePicker.toggle()
                        })
                        {
                            Text("Photos")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle( BorderlessButtonStyle())
                       
                    }
                    if let inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                    } else if let img = getImage(data: vm.book.bookCover) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                    }
                }
                
            }
            .navigationTitle(vm.isNew ? "New Book" : "Edit Book")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveBook()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .sheet(isPresented: $showingCameraController) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    CameraController() { image in
                        inputImage = image
                    }
                }
            }
            .alert("An error occured",
                isPresented: $hasError,
                   actions: {}) {
                Text("The inputs are invalid. Double check your inputs")
            }
        }
        
    }
}


private extension AddBookView {
    func saveBook() {
        if vm.book.isValid {
            vm.book.percent = getProgress(progress: Double(vm.book.progress), length: Double(vm.book.length))
            do {
                if let image = inputImage {
                    vm.book.bookCover = image.pngData()
                }
                try vm.save()
                dismiss()
            } catch {
                print(error)
            }
        }
    }
    
    func getProgress(progress: Double, length: Double) -> Double {
        return progress / length
    }
}


#Preview {
    let previewProvider = BooksProvider.shared

    return AddBookView(vm: .init(provider: previewProvider))
}
