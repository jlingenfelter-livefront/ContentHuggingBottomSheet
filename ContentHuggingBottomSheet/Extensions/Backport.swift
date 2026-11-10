//
//  Backport.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/10/26.
//

import SwiftUI
/// A wrapper for porting functionality from
/// newer iOS versions to earlier ones.
///
/// `Backport` provides an extendable namespace that allows
/// backported functions, properties, and nested types to
/// share the same signature as the original definition.
/// Backported functionality should call the original
/// implementation on supported iOS versions and fallback
/// to custom behavior otherwise.
///
/// The following example illustrates a hypothetical use case where
/// iOS 16 added an imaginary `backgroundColor(_ color: Color)`
/// convenience modifier.
///
/// ```
/// extension Backport where Content: View {
///     @ViewBuilder func backgroundColor(_ color: Color) -> some View {
///         if #available(iOS 16, *) {
///             content.backgroundColor(color)
///         } else {
///             content.background(color)
///         }
///     }
/// }
/// ```
///
/// ```
/// VStack {
///     Text("Hello world")
/// }
/// .backport.backgroundColor(.red)
/// ```
///
public struct Backport<Content> {
    public let content: Content

    public init(_ content: Content) {
        self.content = content
    }
}

extension View {
    var backport: Backport<Self> { Backport(self) }
}
