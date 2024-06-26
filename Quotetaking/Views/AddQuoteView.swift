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
    
    @State private var highlightedText: String? 
    @State private var deviceSupportLiveText = false
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraController = false
    @State private var hasError: Bool = false
    @State private var showLiveTextView = false
    @State private var badInput = false
    
    @ObservedObject var vm: EditQuoteViewModel
    
    var body: some View {
        VStack {
            List {
                Section("Book Info") {
                    TextField("Quote", text: $vm.quote.quote, axis: .vertical)
                    LabeledContent {
                        TextField("25", value: $vm.quote.page , format: .number)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Page number")
                    }
                    TextField("Notes", text: $vm.quote.notes ?? "", axis: .vertical)
                }
                Section("Upload an image to extract quote") {
                    HStack {
                        Button(action: {
                            showingCameraController = true
                            highlightedText = nil
                        }) {
                            Text("Camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle( BorderlessButtonStyle())
                        
                        Button(action: {
                            showingImagePicker = true
                            highlightedText = nil
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
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: inputImage) {
                print($0)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
                    .onDisappear {
                        showLiveTextView.toggle()
                    }
            }
            .sheet(isPresented: $showingCameraController) {
                CameraController() { image in
                    DispatchQueue.main.async {
                        inputImage = image
                    }
                    showLiveTextView.toggle()
                }
            }
        }
        .onAppear {
            self.deviceSupportLiveText = ImageAnalyzer.isSupported
        }
        .sheet(isPresented: $showLiveTextView) {
            
            if let img = inputImage {
                LiveTextView(image: img, highlightedText: $highlightedText)
                    .onDisappear() {
                        DispatchQueue.main.async {
                            inputImage = nil
                            if let text = highlightedText {
                                vm.quote.quote = text
                            }
                        }
                    }
            }
        }
        .alert(isPresented: $badInput) {
            Alert(title: Text("Bad input. Ensure you entered a title, author and length > 0."))
        }
    }
}

private extension AddQuoteView {
    func saveQuote() {
        if vm.quote.isValid {
            do {
                try vm.save()
                dismiss()
            } catch {
                print(error)
            }
        } else {
            badInput = true
        }
    }
}


#Preview {
    let previewProvider = BooksProvider.shared

    return AddQuoteView(vm: .init(provider: previewProvider))
}

