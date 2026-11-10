//
//  View+SafeAreaContent.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/10/26.
//

import SwiftUI

extension View {
    /// Uses `safeAreaBar` when available so scroll edge effects extend beneath the content,
    /// falling back to `safeAreaInset` on earlier OS versions.
    ///
    /// - Parameter fallbackBackground: Applied behind `content` only in the `safeAreaInset` fallback,
    ///   which has no scroll edge effect to separate the content from what scrolls beneath it.
    @ViewBuilder
    func safeAreaContent<Content: View>(
        edge: VerticalEdge,
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        fallbackBackground: Color? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            safeAreaBar(edge: edge, alignment: alignment, spacing: spacing, content: content)
        } else {
            safeAreaInset(edge: edge, alignment: alignment, spacing: spacing) {
                content()
                    .background(fallbackBackground ?? .clear)
            }
        }
    }

    /// Uses `safeAreaBar` when available so scroll edge effects extend beneath the content,
    /// falling back to `safeAreaInset` on earlier OS versions.
    ///
    /// - Parameter fallbackBackground: Applied behind `content` only in the `safeAreaInset` fallback,
    ///   which has no scroll edge effect to separate the content from what scrolls beneath it.
    @ViewBuilder
    func safeAreaContent<Content: View>(
        edge: HorizontalEdge,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        fallbackBackground: Color? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            safeAreaBar(edge: edge, alignment: alignment, spacing: spacing, content: content)
        } else {
            safeAreaInset(edge: edge, alignment: alignment, spacing: spacing) {
                content()
                    .background(fallbackBackground ?? .clear)
            }
        }
    }
}
