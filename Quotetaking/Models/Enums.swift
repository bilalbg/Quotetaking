//
//  enums.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-22.
//

import Foundation

struct SearchConfig: Equatable {
    
//    enum Filter {
//        case all
//    }
    
    var query: String = ""
//    var filter: Filter = .all
    
}
enum SortOrder {
    case asc, desc
}
enum BookSortType {
    case title, author, progress
}
enum QuoteSortType {
    case quote, page
}
