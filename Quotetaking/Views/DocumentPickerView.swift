//
//  DocumentPickerView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2024-10-12.
//

import Foundation
import UIKit
import SwiftUI

import UIKit

struct docPicker: UIViewControllerRepresentable {
    @Binding var doc: Document?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let picker = UIDocumentPickerViewController()
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: docPicker

        init(_ parent: docPicker) {
            self.parent = parent
        }
        
        func didPickDocument(document: Document?) {
            if let pickedDoc = document {
                self.parent.doc = pickedDoc
            }
        }

//        func picker(_ picker: UIDocumentPickerViewController, didFinishPicking results: [Document]) {
//        
//            picker.dismiss(animated: true)
//
//            guard let provider = results.first? else { return }
//
//            if provider.canLoadObject(ofClass: Document.self) {
//                provider.loadObject(ofClass: Document.self) { doc, _ in
//                    DispatchQueue.main.async {
//                        self.parent.doc = image as? Document
//                    }
//                }
//            }
//        }
    }
    typealias UIViewControllerType = UIViewController
    
    
}

//class DocumentPickerContainerViewController: UIViewController {
//
//    weak var delegate: UIDocumentPickerDelegate?
//    var documentPickerViewController : UIDocumentPickerViewController = UIDocumentPickerViewController(
//        forOpeningContentTypes: [.image])
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        documentPickerViewController.delegate = delegate
//        addChild(documentPickerViewController)
//        documentPickerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight ]
//        view.addSubview(documentPickerViewController.view)
//        documentPickerViewController.didMove(toParent: self)
//    }
//    
//    deinit {
//        documentPickerViewController.willMove(toParent: nil)
//        documentPickerViewController.view.removeFromSuperview()
//        documentPickerViewController.removeFromParent()
//    }
//}

//class DocumentPickerViewController: UIViewController, DocumentDelegate {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.pickDoc()
//        
//    }
//    func pickDoc() {
//            let documentPicker = DocumentPicker(presentationController: self, delegate: self)
//           documentPicker.displayPicker()
//         }
//    
////    @IBAction func importTapped() {
////      //Create a picker specifying file type and mode
////      let documentPicker = UIDocumentPickerViewController()
////       documentPicker.delegate = self
////       documentPicker.allowsMultipleSelection = false
////       documentPicker.modalPresentationStyle = .fullScreen
////       present(documentPicker, animated: true, completion: nil)
////    }
//    /// callback from the document picker
//    func didPickDocument(document: Document?) {
//        if let pickedDoc = document {
//            let fileURL = pickedDoc.fileURL
//            print(fileURL)
//            
//            /// do what you want with the file URL
//        }
//    }
//}
