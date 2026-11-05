//
//  View+AdaptiveBottomSheet.swift
//  MyApp
//
//  Created by Jo Lingenfelter on 11/3/26.
//

import SwiftUI

/// Scrolling sheet content with an optional pinned footer, sized to fit both.
private struct AdaptiveSheetContent<SheetContent: View, FooterContent: View>: View {
    @ContentBuilder let sheetContent: () -> SheetContent
    @ContentBuilder let footerContent: () -> FooterContent

    @State private var contentHeight: CGFloat = .zero
    @State private var topInsetHeight: CGFloat = .zero
    @State private var footerHeight: CGFloat = .zero

    private var totalHeight: CGFloat {
        contentHeight + topInsetHeight + footerHeight
    }

    private var isMeasured: Bool {
        contentHeight > 0
    }

    init(
        @ContentBuilder sheetContent: @escaping () -> SheetContent,
        @ContentBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.sheetContent = sheetContent
        self.footerContent = footerContent
    }

    init(
        @ContentBuilder sheetContent: @escaping () -> SheetContent
    ) where FooterContent == EmptyView {
        self.sheetContent = sheetContent
        self.footerContent = { EmptyView() }
    }

    var body: some View {
        ScrollView {
            sheetContent()
                .measuring(\.height, in: .local, assign: $contentHeight.conditionalAnimation(.snappy, when: isMeasured))
        }
        .safeAreaBar(edge: .bottom, spacing: 0, content: {
            footerContent()
                .measuring(\.height, in: .local, assign: $footerHeight.conditionalAnimation(.snappy, when: isMeasured))
        })
        .onGeometryChange(for: CGFloat.self, of: { geometry in
            geometry.safeAreaInsets.top
        }, action: { newValue in
            topInsetHeight = newValue.rounded()
        })
        // Before the content is measured, the total is just the inset and footer, which
        // change with the sheet's size; sizing to them causes a cyclic layout
        .modifier(AnimatedHeightDetent(height: isMeasured ? totalHeight : 0))
        // A large title collapsing on scroll would shrink the top inset and jerk the sheet
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Applies a height detent that SwiftUI interpolates frame by frame
/// whenever `height` changes inside an animation.
@Animatable
private struct AnimatedHeightDetent: ViewModifier {
    var height: CGFloat

    private var detent: PresentationDetent {
        // Until the content has been measured, use a detent large enough for the
        // navigation bar to lay out, so UIKit doesn't break constraints
        guard height > 0 else {
            return .large
        }

        return .height(height)
    }

    func body(content: Content) -> some View {
        content.presentationDetents([detent])
    }
}

/// Presents `AdaptiveSheetContent` in a sheet, inside a `NavigationStack`.
private struct AdaptiveBottomSheetModifier<SheetContent: View, FooterContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ContentBuilder let sheetContent: () -> SheetContent
    @ContentBuilder let footerContent: () -> FooterContent

    init(
        isPresented: Binding<Bool>,
        @ContentBuilder sheetContent: @escaping () -> SheetContent,
        @ContentBuilder footerContent: @escaping () -> FooterContent
    ) {
        _isPresented = isPresented
        self.sheetContent = sheetContent
        self.footerContent = footerContent
    }

    init(
        isPresented: Binding<Bool>,
        @ContentBuilder sheetContent: @escaping () -> SheetContent
    ) where FooterContent == EmptyView {
        _isPresented = isPresented
        self.sheetContent = sheetContent
        self.footerContent = { EmptyView() }
    }

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            NavigationStack {
                AdaptiveSheetContent(sheetContent: sheetContent, footerContent: footerContent)
            }
        }
    }
}

extension View {
    /// Presents a sheet whose height fits its content and animates as the content resizes.
    ///
    /// The content is in a `NavigationStack`, so it can set a navigation title and
    /// toolbar; titles always display inline. Content taller than the screen scrolls.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is presented.
    ///   - content: The sheet's content.
    func adaptiveBottomSheet(
        isPresented: Binding<Bool>,
        @ContentBuilder content: @escaping () -> some View
    ) -> some View {
        self.modifier(AdaptiveBottomSheetModifier(isPresented: isPresented, sheetContent: content))
    }

    /// Presents a sheet whose height fits its content and footer, and animates as they resize.
    ///
    /// The footer stays pinned to the bottom while the content scrolls behind it.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is presented.
    ///   - content: The sheet's scrolling content.
    ///   - footer: A view pinned to the bottom of the sheet, such as a primary button.
    func adaptiveBottomSheet(
        isPresented: Binding<Bool>,
        @ContentBuilder content: @escaping () -> some View,
        @ContentBuilder footer: @escaping () -> some View,
    ) -> some View {
        self.modifier(AdaptiveBottomSheetModifier(isPresented: isPresented, sheetContent: content, footerContent: footer))
    }
}

#Preview {
    AdaptiveSheetContent {
        Color.blue
            .frame(height: 100)
    }
}
