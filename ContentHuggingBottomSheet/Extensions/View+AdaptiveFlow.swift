//
//  View+AdaptiveFlow.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// Presents an `AdaptiveFlow` in a sheet.
private struct AdaptiveFlowModifier<Step: Hashable, StepContent: View, FooterContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let step: Step
    let animation: Animation?
    @ContentBuilder let stepContent: (Step) -> StepContent
    @ContentBuilder let footerContent: (Step) -> FooterContent

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            AdaptiveFlow(
                step: step,
                animation: animation,
                content: stepContent,
                footer: footerContent
            )
        }
    }
}

extension View {
    /// Presents a sheet that steps through content, fitting its height to each step
    /// and animating between them.
    ///
    /// Pass the current step from your own state and change that state directly; the
    /// content transition and the sheet's resize both use `animation`, so they move
    /// together. The content is in a `NavigationStack`, so each step can set a
    /// navigation title and toolbar, such as a back button.
    ///
    /// - Important:`presentationDetents(_:)` should NOT be set on the content. This method
    /// handles measuring the content and setting the detents internally.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is presented.
    ///   - step: The current step. The flow only reads it, so reset the state it comes
    ///     from when the sheet is dismissed to start the next presentation from the
    ///     beginning.
    ///   - animation: The animation for step changes and the sheet's height changes.
    ///     Pass `nil` to change steps and resize the sheet immediately.
    ///   - content: The scrolling content for a step.
    ///   - footer: A view pinned to the bottom of the sheet for a step. It keeps its
    ///     identity across steps, so a single button can change its title and action.
    func adaptiveFlow<Step: Hashable>(
        isPresented: Binding<Bool>,
        step: Step,
        animation: Animation? = .snappy,
        @ContentBuilder content: @escaping (Step) -> some View,
        @ContentBuilder footer: @escaping (Step) -> some View
    ) -> some View {
        modifier(
            AdaptiveFlowModifier(
                isPresented: isPresented,
                step: step,
                animation: animation,
                stepContent: content,
                footerContent: footer
            )
        )
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var step = PreviewStep.intro
    @Previewable @State var selection: Set<PreviewNotification> = [.classReminders, .waitlistUpdates]

    Button("Set Up Notifications") {
        isPresented = true
    }
    .onChange(of: isPresented) { _, isPresented in
        // Start the next presentation from the first step
        if !isPresented {
            step = .intro
        }
    }
    .adaptiveFlow(isPresented: $isPresented, step: step) { current in
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
                        step = previous
                    }
                }
            } else if current == .intro {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        isPresented = false
                    }
                }
            }
        }
    } footer: { current in
        // One button for every step, so only its title and action change
        Button {
            if let next = current.next {
                step = next
            } else {
                isPresented = false
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
