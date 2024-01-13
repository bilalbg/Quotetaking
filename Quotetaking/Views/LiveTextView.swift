//
//  LiveTextView.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-22.
//

import SwiftUI

struct LiveTextView: View {
    @Environment(\.presentationMode) var presentationMode
    
    /*@Binding*/ var image: UIImage/*?*/
    @Binding var highlightedText: String?
    @State var callFunc = false
    
    
    var body: some View {
        NavigationStack {
            if let text = highlightedText {
                Text(text)
                    .frame(alignment: .center)
                    .italic()
            }
            LiveTextInteraction(image: image, highlightedText: $highlightedText, isCallingFunc: $callFunc)
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                highlightedText = nil
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    .interactiveDismissDisabled(true)
            Button {
                callFunc.toggle()
            } label: {
                Text("Extract text")
            }
        }
    }
}

//#Preview {
//    LiveTextView(image: nil)
//}
