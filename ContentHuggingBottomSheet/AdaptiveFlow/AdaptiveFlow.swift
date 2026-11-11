//
//  AdaptiveFlow.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// A multistep sheet that resizes to fit each step.
///
/// Change `step` directly, not inside `withAnimation`. The flow uses `animation` for
/// both the step transition and the resize, so they stay in sync.
///
/// The flow sits in a `NavigationStack`, so each step can set its own title and
/// toolbar. Step content blurs between steps, while the footer updates in place.
///
/// - Important: Don't set `presentationDetents(_:)` on the content.
struct AdaptiveFlow<Step: Hashable, StepContent: View, FooterContent: View>: View {
    /// The step to show.
    let step: Step

    /// Animates step changes and resizing. Pass `nil` to disable.
    var animation: Animation? = .snappy

    /// The content for each step. Scrolls if it doesn't fit.
    @ContentBuilder let content: (Step) -> StepContent

    /// A view pinned below the content. It persists across steps, so one button can
    /// change its title and action.
    @ContentBuilder let footer: (Step) -> FooterContent

    var body: some View {
        NavigationStack {
            AdaptiveSheet(animation: animation) {
                ZStack(alignment: .top) {
                    content(step)
                        // A new identity per step, so steps that use the same view
                        // type still transition
                        .id(step)
                        .transition(.blurReplace)
                }
            } footerContent: {
                // Keeps its identity across steps, so it updates in place
                footer(step)
                    .transition(.blurReplace)
            }
            .animation(animation, value: step)
        }
    }
}

#Preview {
    @Previewable @State var isPresentingSheet = true

    Button("Set Up Notifications") {
        isPresentingSheet = true
    }
    .sheet(isPresented: $isPresentingSheet) {
        PreviewNotificationFlow()
    }
}
