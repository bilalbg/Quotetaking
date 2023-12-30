//
//  LiveTextInteraction.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-23.
//

import UIKit
import SwiftUI
import VisionKit

@MainActor
struct LiveTextInteraction: UIViewRepresentable {
    var image: UIImage
    let imageView = LiveTextImageView()
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    @Binding var highlightedText: String?
    @Binding var isCallingFunc: Bool
    
    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.addInteraction(interaction)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task { @MainActor in 
            let configuration = ImageAnalyzer.Configuration([.text])
            do {
                if let image = imageView.image {
                    let analysis = try await analyzer.analyze(image, configuration: configuration)
                    interaction.analysis = analysis
                    interaction.preferredInteractionTypes = .automaticTextOnly
                    
                }
            } catch {
                fatalError("Print Error occured: \(error)")
            }
        }
        if isCallingFunc {
            isCallingFunc.toggle()
            self.getText()
        }
    }
    
    func getText() {
        self.highlightedText = self.interaction.selectedText
    }
}

class LiveTextImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        .zero
    }
}

