//
//  View+AdaptiveBottomSheet.swift
//  MyApp
//
//  Created by Jo Lingenfelter on 11/3/26.
//

import SwiftUI

/// Scrolling sheet content with an optional pinned footer, sized to fit both.
private struct AdaptiveSheetContent<SheetContent: View, FooterContent: View>: View {
    let animation: Animation?
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
                .measuringAnimatedValue(\.height, in: .local, assign: $footerHeight, animation: animation)
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
                AdaptiveSheetContent(
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
            .scenePadding()
        }
    )
}

