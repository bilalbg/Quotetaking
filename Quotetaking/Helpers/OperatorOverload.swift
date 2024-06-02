//
//  optionalOverride.swift
//  Quotetaking
//
//  Created by Bilal Baig on 2024-06-02.
//

import SwiftUI

public extension Binding {
    /// Create a non-optional version of an optional `Binding` with a default value
    /// - Parameters:
    ///   - lhs: The original `Binding<Value?>` (binding to an optional value)
    ///   - rhs: The default value if the original `wrappedValue` is `nil`
    /// - Returns: The `Binding<Value>` (where `Value` is non-optional)
    static func ??(lhs: Binding<Optional<Value>>, rhs: Value) -> Binding<Value> {
        Binding {
            lhs.wrappedValue ?? rhs
        } set: {
            lhs.wrappedValue = $0
        }
    }
}
