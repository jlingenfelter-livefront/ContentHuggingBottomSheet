import SwiftUI

@main struct MyApp: App {
    @State private var isSheetPresented: Bool = false
    @State private var isFlowPresented: Bool = false
    @State private var flowStep: PreviewStep = .intro
    @State private var notificationSelection: Set<PreviewNotification> = [.classReminders, .waitlistUpdates]

    var body: some Scene {
        WindowGroup {
            VStack {
                Button("Show Sheet!") {
                    isSheetPresented = true
                }

                Button("Show Flow!") {
                    isFlowPresented = true
                }
            }
            .adaptiveBottomSheet(
                isPresented: $isSheetPresented,
                content: { PreviewSheetContent() },
                footer: {
                    Button {
                        isSheetPresented = false
                    } label: {
                        Text("Turn On")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .scenePadding(.horizontal)
                }
            )
            .onChange(of: isFlowPresented) { _, isPresented in
                // Start the next presentation from the first step
                if !isPresented {
                    flowStep = .intro
                }
            }
            .adaptiveFlow(isPresented: $isFlowPresented, step: $flowStep) { current in
                Group {
                    switch current {
                    case .intro:
                        PreviewIntroStep()
                            .navigationTitle("Notifications")
                    case .choose:
                        PreviewChooseStep(selection: $notificationSelection)
                            .navigationTitle("Choose Notifications")
                    case .done:
                        PreviewDoneStep(selection: notificationSelection)
                    }
                }
                .toolbar {
                    if let previous = current.previous {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Back", systemImage: "chevron.backward") {
                                withAnimation(.snappy) {
                                    flowStep = previous
                                }
                            }
                        }
                    } else if current == .intro {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close", systemImage: "xmark") {
                                isFlowPresented = false
                            }
                        }
                    }
                }
            } footer: { current in
                // One button for every step, so only its title and action change
                Button {
                    if let next = current.next {
                        withAnimation(.snappy) {
                            flowStep = next
                        }
                    } else {
                        isFlowPresented = false
                    }
                } label: {
                    Text(current.footerTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(current == .choose && notificationSelection.isEmpty)
                .scenePadding(.horizontal)
            }
        }
    }
}
