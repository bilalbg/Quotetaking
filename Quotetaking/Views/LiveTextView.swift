//
//  LiveTextView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-22.
//

import SwiftUI

struct LiveTextView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var image: UIImage
    
    var body: some View {
        NavigationStack {
            LiveTextInteraction(image: image)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .interactiveDismissDisabled(true)
        }
        .onAppear {
            print(image.pngData())
        }
    }
}

//#Preview {
//    LiveTextView(image: nil)
//}
