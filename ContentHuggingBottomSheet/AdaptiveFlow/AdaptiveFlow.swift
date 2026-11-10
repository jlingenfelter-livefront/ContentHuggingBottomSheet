//
//  AdaptiveFlow.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// Steps through content inside one `AdaptiveSheet`, in a `NavigationStack`, so the
/// sheet animates between each step's height.
///
/// Step changes and the sheet's resize both use `animation`, so set `step` directly
/// rather than inside `withAnimation`. Pass `nil` to change steps and resize immediately.
struct AdaptiveFlow<Step: Hashable, StepContent: View, FooterContent: View>: View {
    let step: Step
    var animation: Animation? = .snappy
    @ContentBuilder let content: (Step) -> StepContent
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
