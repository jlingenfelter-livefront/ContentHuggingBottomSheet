//
//  Binding+ConditionalAnimation.swift
//  MyApp
//

import SwiftUI

extension Binding {
    /// Like `animation(_:)`, but only animates changes while `condition` is true;
    /// otherwise the binding is returned unchanged.
    func conditionalAnimation(_ animation: Animation? = .default, when condition: Bool) -> Binding<Value> {
        condition ? self.animation(animation) : self
    }
}
