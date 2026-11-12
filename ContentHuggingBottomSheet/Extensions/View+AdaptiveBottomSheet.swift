//
//  View+AdaptiveBottomSheet.swift
//  MyApp
//
//  Created by Jo Lingenfelter on 11/3/26.
//

import SwiftUI

extension View {
    /// Presents a sheet whose height fits its content and animates as the content resizes.
    ///
    /// The content is in a `NavigationStack`, so it can set a navigation title and
    /// toolbar; titles display inline by default. Content taller than the screen scrolls.
    ///
    /// - Note: Setting `navigationBarTitleDisplayMode(.large)` on the content overrides
    ///   the inline default, and the sheet resizes as the large title scrolls into the
    ///   navigation bar.
    ///
    /// - Important:`presentationDetents(_:)` should NOT be set on the content. This method
    /// handles measuring the content and setting the detents internally.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is presented.
    ///   - animation: The animation for the sheet's height changes. Match the animation
    ///     the content resizes with, so the sheet and content move together. Pass `nil`
    ///     to resize the sheet immediately.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: The sheet's content.
    func adaptiveBottomSheet(
        isPresented: Binding<Bool>,
        animation: Animation? = .snappy,
        onDismiss: (() -> Void)? = nil,
        @ContentBuilder content: @escaping () -> some View
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
            NavigationStack {
                AdaptiveSheet(
                    animation: animation,
                    content: content
                )
            }
        }
    }

    /// Presents a sheet whose height fits its content and footer, and animates as they resize.
    ///
    /// Content that doesn't fit scrolls beneath the pinned footer.
    ///
    /// - Note: Setting `navigationBarTitleDisplayMode(.large)` on the content overrides
    ///   the inline default, and the sheet resizes as the large title scrolls into the
    ///   navigation bar.
    ///
    /// - Important:`presentationDetents(_:)` should NOT be set on the content. This method
    /// handles measuring the content and setting the detents internally.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is presented.
    ///   - animation: The animation for the sheet's height changes. Match the animation
    ///     the content and footer resize with, so the sheet and content move together.
    ///     Pass `nil` to resize the sheet immediately.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - content: The sheet's content. Scrolls if it doesn't fit.
    ///   - footer: A view pinned to the bottom of the sheet, such as a primary button.
    func adaptiveBottomSheet(
        isPresented: Binding<Bool>,
        animation: Animation? = .snappy,
        onDismiss: (() -> Void)? = nil,
        @ContentBuilder content: @escaping () -> some View,
        @ContentBuilder footer: @escaping () -> some View,
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
            NavigationStack {
                AdaptiveSheet(
                    animation: animation,
                    content: content,
                    footer: footer,
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true

    Button("Show Sheet!") {
        isPresented = true
    }
    .adaptiveBottomSheet(
        isPresented: $isPresented,
        content: { PreviewSheetContent() },
        footer: {
            Button {
                isPresented = false
            } label: {
                Text("Turn On")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.backport(.glassProminent))
            .controlSize(.large)
            .scenePadding(.horizontal)
        }
    )
}

