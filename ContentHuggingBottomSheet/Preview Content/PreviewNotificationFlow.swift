//
//  PreviewNotificationFlow.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//

import SwiftUI

/// A notification setup flow that owns its step, so each presentation starts
/// from the first step.
struct PreviewNotificationFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step = PreviewStep.intro
    @State private var selection: Set<PreviewNotification> = [.classReminders, .waitlistUpdates]

    var body: some View {
        AdaptiveFlow(step: step) { current in
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
                            dismiss()
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
                    dismiss()
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
}

#Preview {
    @Previewable @State var isPresented = true

    Button("Set Up Notifications") {
        isPresented = true
    }
    .sheet(isPresented: $isPresented) {
        PreviewNotificationFlow()
    }
}
