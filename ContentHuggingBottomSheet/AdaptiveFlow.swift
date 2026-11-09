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

/// Presents an `AdaptiveFlow` in a sheet.
private struct AdaptiveFlowModifier<Step: Hashable, StepContent: View, FooterContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var step: Step
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
    /// Change `step` inside an animation matching `animation`, so the content
    /// transition and the sheet's resize move together. The content is in a
    /// `NavigationStack`, so each step can set a navigation title and toolbar, such
    /// as a back button.
    ///
    /// - Important:`presentationDetents(_:)` should NOT be set on the content. This method
    /// handles measuring the content and setting the detents internally.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is presented.
    ///   - step: The current step. Reset it when the sheet is dismissed to start
    ///     the next presentation from the beginning.
    ///   - animation: The animation for the sheet's height changes. Pass `nil` to
    ///     resize the sheet immediately.
    ///   - content: The scrolling content for a step.
    ///   - footer: A view pinned to the bottom of the sheet for a step. It keeps its
    ///     identity across steps, so a single button can change its title and action.
    func adaptiveFlow<Step: Hashable>(
        isPresented: Binding<Bool>,
        step: Binding<Step>,
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

// MARK: - Preview

/// The steps of a notification opt-in flow.
private enum PreviewStep {
    case intro, choose, done

    /// The step the footer button advances to, or `nil` on the last step.
    var next: PreviewStep? {
        switch self {
        case .intro: .choose
        case .choose: .done
        case .done: nil
        }
    }

    /// The step the back button returns to, or `nil` where going back doesn't apply.
    var previous: PreviewStep? {
        switch self {
        case .choose: .intro
        case .intro, .done: nil
        }
    }

    var footerTitle: String {
        switch self {
        case .intro: "Continue"
        case .choose: "Turn On"
        case .done: "Done"
        }
    }
}

private enum PreviewNotification: CaseIterable, Hashable {
    case classReminders, waitlistUpdates, scheduleChanges

    var title: String {
        switch self {
        case .classReminders: "Class reminders"
        case .waitlistUpdates: "Waitlist updates"
        case .scheduleChanges: "Schedule changes"
        }
    }

    var detail: String {
        switch self {
        case .classReminders: "An hour before a class you've booked."
        case .waitlistUpdates: "When a spot opens up in a full class."
        case .scheduleChanges: "When a class is moved, cancelled, or gets a new instructor."
        }
    }

    var systemImage: String {
        switch self {
        case .classReminders: "calendar"
        case .waitlistUpdates: "person.2"
        case .scheduleChanges: "arrow.triangle.2.circlepath"
        }
    }
}

private struct PreviewIntroStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)

            Text("Never miss a class")
                .font(.title2.bold())

            Text("Get a heads-up before your classes start, and be the first to know when a spot opens up.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

private struct PreviewChooseStep: View {
    @Binding var selection: Set<PreviewNotification>

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose what you'd like to hear about. You can change this anytime in Settings.")
                .foregroundStyle(.secondary)

            ForEach(PreviewNotification.allCases, id: \.self) { notification in
                Toggle(isOn: isSelected(notification)) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(notification.title)
                            Text(notification.detail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: notification.systemImage)
                    }
                }
            }
        }
        .padding()
    }

    private func isSelected(_ notification: PreviewNotification) -> Binding<Bool> {
        Binding {
            selection.contains(notification)
        } set: { isOn in
            if isOn {
                selection.insert(notification)
            } else {
                selection.remove(notification)
            }
        }
    }
}

private struct PreviewDoneStep: View {
    let selection: Set<PreviewNotification>

    private var summary: String {
        // Keeps the list in the same order as the toggles
        PreviewNotification.allCases
            .filter(selection.contains)
            .map(\.title)
            .formatted(.list(type: .and))
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)

            Text("You're all set")
                .font(.title2.bold())

            Text("We'll send you \(summary.lowercased()).")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
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
