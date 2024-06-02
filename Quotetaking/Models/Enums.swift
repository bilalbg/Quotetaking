//
//  enums.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-22.
//

import Foundation

struct SearchConfig: Equatable {
    
    var query: String = ""
    
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
