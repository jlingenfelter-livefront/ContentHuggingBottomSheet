//
//  View+ProminentButtonStyle.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/10/26.
//

import SwiftUI

/// A button style that applies Liquid Glass styles where available,
/// falling back to the equivalent bordered styles on earlier versions.
///
/// ```
/// Button("Turn On") { }
///     .buttonStyle(.backport(.glassProminent))
/// ```
struct BackportButtonStyle: PrimitiveButtonStyle {
    enum Style {
        /// `.glass`, falling back to `.bordered`.
        case glass
        /// `.glassProminent`, falling back to `.borderedProminent`.
        case glassProminent
    }

    let style: Style

    func makeBody(configuration: Configuration) -> some View {
        switch style {
        case .glass:
            if #available(iOS 26, macOS 26, visionOS 26, *) {
                Button(configuration).buttonStyle(.glass)
            } else {
                Button(configuration).buttonStyle(.bordered)
            }
        case .glassProminent:
            if #available(iOS 26, macOS 26, visionOS 26, *) {
                Button(configuration).buttonStyle(.glassProminent)
            } else {
                Button(configuration).buttonStyle(.borderedProminent)
            }
        }
    }
}

extension PrimitiveButtonStyle where Self == BackportButtonStyle {
    static func backport(_ style: BackportButtonStyle.Style) -> Self {
        BackportButtonStyle(style: style)
    }
}
