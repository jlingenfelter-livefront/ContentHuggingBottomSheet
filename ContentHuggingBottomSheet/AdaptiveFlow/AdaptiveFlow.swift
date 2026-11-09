//
//  AdaptiveFlow.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// Steps through content inside one `AdaptiveSheet`, in a `NavigationStack`, so the
/// sheet animates between each step's height.
struct AdaptiveFlow<Step: Hashable, StepContent: View, FooterContent: View>: View {
    let step: Step
    let animation: Animation?
    @ContentBuilder let content: (Step) -> StepContent
    @ContentBuilder let footer: (Step) -> FooterContent

    var body: some View {
        NavigationStack {
            AdaptiveSheet(animation: animation) {
                // Overlaps the outgoing and incoming steps during the transition,
                // instead of stacking them
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
