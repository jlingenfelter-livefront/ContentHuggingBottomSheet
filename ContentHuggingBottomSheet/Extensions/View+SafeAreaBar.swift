//
//  View+SafeAreaBar.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/10/26.
//

import SwiftUI

extension Backport where Content: View {
    /// Uses `safeAreaBar` when available so scroll edge effects extend beneath the content,
    /// falling back to `safeAreaInset` on earlier OS versions.
    @ViewBuilder
    func safeAreaBar<BarContent: View>(
        edge: VerticalEdge,
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> BarContent
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.content.safeAreaBar(
                edge: edge,
                alignment: alignment,
                spacing: spacing,
                content: content
            )
        } else {
            self.content.safeAreaInset(
                edge: edge,
                alignment: alignment,
                spacing: spacing,
                content: content
            )
        }
    }

    /// Uses `safeAreaBar` when available so scroll edge effects extend beneath the content,
    /// falling back to `safeAreaInset` on earlier OS versions.
    @ViewBuilder
    func safeAreaBar<BarContent: View>(
        edge: HorizontalEdge,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> BarContent
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.content.safeAreaBar(
                edge: edge,
                alignment: alignment,
                spacing: spacing,
                content: content
            )
        } else {
            self.content.safeAreaInset(
                edge: edge,
                alignment: alignment,
                spacing: spacing,
                content: content
            )
        }
    }
}
