//
//  Quote.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2023-12-21.
//


import Foundation
import CoreData

final class Quote: NSManagedObject, Identifiable {
    
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var quote: String
    @NSManaged var page: Int
    
    var isValid: Bool {
        !title.isEmpty &&
        !author.isEmpty &&
        !quote.isEmpty &&
        !(page == 0)
    }
    
}
