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
    
    @ObservedObject var vm: EditBookViewModel
    
    var imageView = UIImageView()
    
    @State var badInput = false
    
    var body: some View {
        
        VStack {
            List {
                Section("Book Info") {
                    
                    TextField("Title", text: $vm.book.title, axis: .vertical)
                    TextField("Author", text: $vm.book.author)
                    LabeledContent {
                        TextField("0", value: $vm.book.progress , format: .number)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                            
                    } label: {
                        Text("Progress in Book")
                    }
                    LabeledContent {
                        TextField("300", value: $vm.book.length, format: .number)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Length of Book")
                    }
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
                        Button(action: {
                            vm.book.bookCover = nil
                            inputImage = nil
                        })
                        {
                            Text("Clear")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle( BorderlessButtonStyle())
                       
                    }
                    if let inputImage {
                        Image(uiImage: inputImage)
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
        }
        .onAppear {
            if !vm.isNew {
                inputImage = getImage(data: vm.book.bookCover)
            }
        }
        .alert(isPresented: $badInput) {
            Alert(title: Text("Bad input. Ensure you entered a title, author and length > 0."))
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
                } else {
                    vm.book.bookCover = UIImage(systemName: "book.closed.fill")?.withTintColor(.brown).pngData()
                }
                try vm.save()
                dismiss()
            } catch {
                print(error)
            }
        } else {
            badInput = true
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
