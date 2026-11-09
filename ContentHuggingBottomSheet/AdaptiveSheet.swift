//
//  AdaptiveSheet.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// Scrolling sheet content with an optional pinned footer, sized to fit both.
struct AdaptiveSheet<SheetContent: View, FooterContent: View>: View {
    let animation: Animation?
    @ContentBuilder let sheetContent: () -> SheetContent
    @ContentBuilder let footerContent: () -> FooterContent

    @State private var contentHeight: CGFloat?
    @State private var topInsetHeight: CGFloat?
    @State private var footerHeight: CGFloat?

    private var totalHeight: CGFloat? {
        guard let contentHeight, let footerHeight, let topInsetHeight else {
            return nil
        }

        return contentHeight + topInsetHeight + footerHeight
    }

    init(
        animation: Animation?,
        @ContentBuilder sheetContent: @escaping () -> SheetContent,
        @ContentBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.animation = animation
        self.sheetContent = sheetContent
        self.footerContent = footerContent
    }

    init(
        animation: Animation?,
        @ContentBuilder sheetContent: @escaping () -> SheetContent
    ) where FooterContent == EmptyView {
        self.animation = animation
        self.sheetContent = sheetContent
        self.footerContent = { EmptyView() }
    }

    var body: some View {
        ScrollView {
            sheetContent()
                .measuringAnimatedValue(\.height, in: .local, assign: $contentHeight, animation: animation)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaBar(edge: .bottom, spacing: 0, content: {
            footerContent()
                // Prevents an empty view or a view lacking an intrinsic size from stretching vertically to fill the the available space
                .fixedSize(horizontal: false, vertical: true)
                .measuringAnimatedValue(\.height, in: .local, assign: $footerHeight, animation: animation)
        })
        .onGeometryChange(for: CGFloat.self, of: {
            $0.safeAreaInsets.top
        }, action: { newValue in
            topInsetHeight = newValue.rounded()
        })
        // Before the content is measured, the total is just the inset and footer, which
        // change with the sheet's size; sizing to them causes a cyclic layout
        .modifier(AnimatedHeightDetent(height: totalHeight ?? 0))
        // A large title collapsing on scroll would shrink the top inset and jerk the sheet
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Applies a height detent that SwiftUI interpolates frame by frame
/// whenever `height` changes inside an animation.
@Animatable
private struct AnimatedHeightDetent: ViewModifier {
    var height: CGFloat

    private var detents: Set<PresentationDetent> {
        // Until the content has a measured height, or if it never reports one, fall
        // back to flexible detents the user can drag between. Both are large enough
        // for the navigation bar to lay out, so UIKit doesn't break constraints
        guard height > 0 else {
            return [.medium, .large]
        }

        return [.height(height)]
    }

    func body(content: Content) -> some View {
        content.presentationDetents(detents)
    }
}
