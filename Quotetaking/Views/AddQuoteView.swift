//
//  InputView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

// New quote entry view
import SwiftUI

struct AddQuoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraController = false
    @State private var hasError: Bool = false
    
    @ObservedObject var vm: EditQuoteViewModel
    
    
    var body: some View {
        VStack {
        //update values to non optional when db is fixed
            List {
                Section("Book Info") {
                    TextField("Quote", text: $vm.quote.quote)
                    TextField("Page number", value: $vm.quote.page , format: .number)
                        .keyboardType(.phonePad)                    //image field : Image of text (optional)
                    //TextField("Quote", text: $quote ) (optional, this or above required)
                    //TextField("page number", value: $page, format: .number)
                }
                Section("Upload an image to extract quote") {
                    HStack {
                        Button(action: {
                            showingCameraController = true
                        }) {
                            Text("Camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle( BorderlessButtonStyle())
                        
                        Button(action: {
                            showingImagePicker = true
                        })
                        {
                            Text("Photos")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle( BorderlessButtonStyle())
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveQuote()
                        print(vm.quote)
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
                CameraController(image: $inputImage)
            }
        }
    }
}

private extension AddQuoteView {
    func saveQuote() {
        if vm.quote.isValid {
            do {
                print(vm.quote)
                try vm.save()
                dismiss()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    let previewProvider = BooksProvider.shared

    return AddQuoteView(vm: .init(provider: previewProvider))
}

