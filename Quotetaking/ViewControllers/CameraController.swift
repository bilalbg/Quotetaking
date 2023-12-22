//
//  CameraController.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-21.
//

import PhotosUI
import SwiftUI

struct CameraController: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .camera
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraController>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraController>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraController
        init(_ parent: CameraController) {
            self.parent = parent
        }
        
        func picker(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.parent.image = image
            } else {
                print("fail")
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
