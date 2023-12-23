//
//  InputView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-16.
//

// New quote entry view
import SwiftUI
import VisionKit

struct AddQuoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var deviceSupportLiveText = false
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraController = false
    @State private var hasError: Bool = false
    @State private var showLiveTextView = false
    
    @ObservedObject var vm: EditQuoteViewModel
    
    
    var body: some View {
        VStack {
        //update values to non optional when db is fixed
            List {
                Section("Book Info") {
                    TextField("Quote", text: $vm.quote.quote)
                    TextField("Page number", value: $vm.quote.page , format: .number)
                        .keyboardType(.phonePad)
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
                    .onSubmit {
                        showLiveTextView.toggle()
                    }
            }
            .sheet(isPresented: $showingCameraController) {
                CameraController(image: $inputImage)
                    .onSubmit {
                        showLiveTextView.toggle()
                    }
            }
        }
        .onAppear {
            self.deviceSupportLiveText = ImageAnalyzer.isSupported
        }
        .sheet(isPresented: $showLiveTextView) {
            if let image = inputImage {
                LiveTextView(image: image)
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

