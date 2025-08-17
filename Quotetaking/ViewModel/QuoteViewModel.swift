//
//  QuoteViewModel.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2024-06-20.
//

import SwiftUI

class QuoteViewModel: ObservableObject {
    
    @Published var items: [Quote] = []
    var quotes: [Quote] = []
    
    //3
    static private var itemsPerPage = 8
    private var start = -QuoteViewModel.itemsPerPage
    private var stop = -1
    
    private func incrementPaginationIndices() {
      start += QuoteViewModel.itemsPerPage
      stop += QuoteViewModel.itemsPerPage
    }
    
    private func retrieveDataFromAPI(completion: (() -> Void)? = nil) {
        
        let newData =  quotes[self.start...self.stop]
        self.items.append(contentsOf: newData)
//      }
    }
    
    //4
    func getData(completion: (() -> Void)? = nil) {

      incrementPaginationIndices()
      retrieveDataFromAPI(completion: completion)
    }
  }

  //5
  extension Int: Identifiable {
    public var id: Int {
      return self
    }
}
