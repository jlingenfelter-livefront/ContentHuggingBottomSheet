//
//  AdaptiveSheet.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// Sheet content with an optional pinned footer, sized to fit its content.
///
/// Content that is too tall for the available space scrolls beneath the footer. Until the content,
/// is measured the sheet uses the medium and large detents. Medium and large detents will also
/// be used if the content does not have an intrinsic height.
///
/// Place `AdaptiveSheet` in a `NavigationStack`. It doesn't create one, so it can be
/// pushed onto an existing stack. Set the background color on the stack so it fills
/// the safe areas:
///
/// ```swift
/// NavigationStack {
///     AdaptiveSheet(animation: .snappy) {
///         content
///     }
/// }
/// .background(.blue)
/// ```
///
/// - Important: Don't set `presentationDetents(_:)` on the content.  Detents are
/// handled internally.
struct AdaptiveSheet<SheetContent: View, FooterContent: View>: View {
    /// Animates height changes. Pass `nil` to disable.
    let animation: Animation?

    /// The sheet's content. Scrolls if it doesn't fit.
    @ContentBuilder let sheetContent: () -> SheetContent

    /// A view pinned below the content.
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

    /// Creates a content-hugging sheet with a pinned footer.
    ///
    /// - Parameters:
    ///   - animation: Animates height changes. Pass `nil` to disable.
    ///   - sheetContent: The sheet's content. Scrolls if it doesn't fit.
    ///   - footerContent: A view pinned below the content.
    init(
        animation: Animation?,
        @ContentBuilder sheetContent: @escaping () -> SheetContent,
        @ContentBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.animation = animation
        self.sheetContent = sheetContent
        self.footerContent = footerContent
    }

    /// Creates a content-hugging sheet without a footer.
    ///
    /// - Parameters:
    ///   - animation: Animates height changes. Pass `nil` to disable.
    ///   - sheetContent: The sheet's content. Scrolls if it doesn't fit.
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
        // While the sheet animates to a new height, the content briefly overflows
        // under the footer, which would make the edge effect flicker
        .backport.scrollEdgeEffectHidden(true, for: .bottom)
        .backport.safeAreaBar(edge: .bottom, spacing: 0) {
            footerContent()
                // Prevents an empty view or a view lacking an intrinsic size from stretching vertically to fill the the available space
                .fixedSize(horizontal: false, vertical: true)
                .measuringAnimatedValue(\.height, in: .local, assign: $footerHeight, animation: animation)
        }
        .onGeometryChange(for: CGFloat.self, of: {
            $0.safeAreaInsets.top
        }, action: { newValue in
            topInsetHeight = newValue.rounded()
        })
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

#Preview {
    @Previewable @State var isPresentingSheet = false

    Button("Press me!") {
        isPresentingSheet = true
    }
    .sheet(isPresented: $isPresentingSheet) {
        NavigationStack {
            AdaptiveSheet(
                animation: .snappy,
                sheetContent: {
                    PreviewSheetContent()
                },
                footerContent: {
                    Button("Close") {
                        isPresentingSheet = false
                    }
                    .buttonStyle(.glassProminent)
                }
            )
        }
    }
}
