//
//  View+ProminentButtonStyle.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/10/26.
//

import SwiftUI

extension View {
    /// Applies `.glassProminent` where available, falling back to `.borderedProminent`.
    @ViewBuilder
    func prominentButtonStyle() -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
        }
    }
}
