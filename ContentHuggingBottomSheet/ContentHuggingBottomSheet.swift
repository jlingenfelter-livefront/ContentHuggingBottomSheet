//
//  ContentHuggingBottomSheet.swift
//  MyApp
//
//  Created by Jo Lingenfelter on 11/3/26.
//

import SwiftUI

struct ContentHuggingBottomSheet<SheetContent: View, FooterContent: View>: View {
    @ContentBuilder let sheetContent: () -> SheetContent
    @ContentBuilder let footerContent: () -> FooterContent

    @State private var contentHeight: CGFloat = .zero
    @State private var verticalInsetHeight: CGFloat = .zero

    private var totalHeight: CGFloat {
        contentHeight + verticalInsetHeight
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
        NavigationStack {
            ScrollView {
                sheetContent()
                    .measuring(\.height, assign: $contentHeight)
                    .onGeometryChange(for: CGFloat.self, of: { geometry in
                        geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                    }, action: { newValue in
                        if newValue.rounded(.up) > verticalInsetHeight.rounded(.up) {
                            verticalInsetHeight = newValue.rounded(.up)
                        }
                    })
            }
            .ignoresSafeArea(edges: .bottom)
            .safeAreaBar(edge: .bottom, spacing: 0, content: footerContent)
//            .ignoresSafeArea(edges: .bottom)
//            .onGeometryChange(for: CGFloat.self, of: { geometry in
//                geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
//            }, action: { newValue in
//                if newValue.rounded(.up) > verticalInsetHeight.rounded(.up) {
//                    verticalInsetHeight = newValue.rounded(.up)
//                }
//            })
        }
        .frame(maxHeight: totalHeight)
        .presentationDetents([.height(totalHeight)])
    }
}

struct ContentHuggingBottomSheetModifier<SheetContent: View, FooterContent: View>: ViewModifier {
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
            ContentHuggingBottomSheet(sheetContent: sheetContent, footerContent: footerContent)
        }
    }
}

extension View {
    func contentHuggingBottomSheet(
        isPresented: Binding<Bool>,
        @ContentBuilder content: @escaping () -> some View
    ) -> some View {
        self.modifier(ContentHuggingBottomSheetModifier(isPresented: isPresented, sheetContent: content))
    }

    func contentHuggingBottomSheet(
        isPresented: Binding<Bool>,
        @ContentBuilder content: @escaping () -> some View,
        @ContentBuilder footer: @escaping () -> some View,
    ) -> some View {
        self.modifier(ContentHuggingBottomSheetModifier(isPresented: isPresented, sheetContent: content, footerContent: footer))
    }
}

#Preview {
    ContentHuggingBottomSheet {
        Color.blue
            .frame(height: 2000)
    }
}
