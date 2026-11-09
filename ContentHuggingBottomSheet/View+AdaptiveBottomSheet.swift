//
//  View+AdaptiveBottomSheet.swift
//  MyApp
//
//  Created by Jo Lingenfelter on 11/3/26.
//

import SwiftUI

/// Presents `AdaptiveSheetContent` in a sheet, inside a `NavigationStack`.
private struct AdaptiveBottomSheetModifier<SheetContent: View, FooterContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let animation: Animation?
    @ContentBuilder let sheetContent: () -> SheetContent
    @ContentBuilder let footerContent: () -> FooterContent

    init(
        isPresented: Binding<Bool>,
        animation: Animation?,
        @ContentBuilder sheetContent: @escaping () -> SheetContent,
        @ContentBuilder footerContent: @escaping () -> FooterContent
    ) {
        _isPresented = isPresented
        self.animation = animation
        self.sheetContent = sheetContent
        self.footerContent = footerContent
    }

    init(
        isPresented: Binding<Bool>,
        animation: Animation?,
        @ContentBuilder sheetContent: @escaping () -> SheetContent
    ) where FooterContent == EmptyView {
        _isPresented = isPresented
        self.animation = animation
        self.sheetContent = sheetContent
        self.footerContent = { EmptyView() }
    }

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            NavigationStack {
                AdaptiveSheet(
                    animation: animation,
                    sheetContent: sheetContent,
                    footerContent: footerContent
                )
            }
        }
    }
}

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
    ///   - content: The sheet's content.
    func adaptiveBottomSheet(
        isPresented: Binding<Bool>,
        animation: Animation? = .snappy,
        @ContentBuilder content: @escaping () -> some View
    ) -> some View {
        self.modifier(AdaptiveBottomSheetModifier(isPresented: isPresented, animation: animation, sheetContent: content))
    }

    /// Presents a sheet whose height fits its content and footer, and animates as they resize.
    ///
    /// The footer stays pinned to the bottom while the content scrolls behind it.
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
    ///   - content: The sheet's scrolling content.
    ///   - footer: A view pinned to the bottom of the sheet, such as a primary button.
    func adaptiveBottomSheet(
        isPresented: Binding<Bool>,
        animation: Animation? = .snappy,
        @ContentBuilder content: @escaping () -> some View,
        @ContentBuilder footer: @escaping () -> some View,
    ) -> some View {
        self.modifier(
            AdaptiveBottomSheetModifier(
                isPresented: isPresented,
                animation: animation,
                sheetContent: content,
                footerContent: footer
            )
        )
    }
}

#Preview {
    @Previewable @State var isPresented = true

    Button("Show Sheet!") {
        isPresented = true
    }
    .adaptiveBottomSheet(
        isPresented: $isPresented,
        content: { PreviewSheetContent(isPresented: $isPresented) },
        footer: {
            Button {
                isPresented = false
            } label: {
                Text("Turn On")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .scenePadding(.horizontal)
        }
    )
}

