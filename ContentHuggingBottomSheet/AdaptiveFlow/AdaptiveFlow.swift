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
    @Previewable @State var isPresentingSheet = false
    @Previewable @State var step = PreviewStep.intro
    @Previewable @State var selection: Set<PreviewNotification> = [.classReminders, .waitlistUpdates]

    Button("Set Up Notifications") {
        isPresentingSheet = true
    }
    .onChange(of: isPresentingSheet) { _, isPresented in
        // Start the next presentation from the first step
        if !isPresented {
            step = .intro
        }
    }
    .adaptiveFlow(isPresented: $isPresentingSheet, step: $step) { current in
        Group {
            switch current {
            case .intro:
                PreviewIntroStep()
                    .navigationTitle("Notifications")
            case .choose:
                PreviewChooseStep(selection: $selection)
                    .navigationTitle("Choose Notifications")
            case .done:
                PreviewDoneStep(selection: selection)
            }
        }
        .toolbar {
            if let previous = current.previous {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.backward") {
                        withAnimation(.snappy) {
                            step = previous
                        }
                    }
                }
            } else if current == .intro {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        isPresentingSheet = false
                    }
                }
            }
        }
    } footer: { current in
        // One button for every step, so only its title and action change
        Button {
            if let next = current.next {
                withAnimation(.snappy) {
                    step = next
                }
            } else {
                isPresentingSheet = false
            }
        } label: {
            Text(current.footerTitle)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .disabled(current == .choose && selection.isEmpty)
        .scenePadding(.horizontal)
    }
}
