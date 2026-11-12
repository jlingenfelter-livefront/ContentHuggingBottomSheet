import SwiftUI

@main struct MyApp: App {
    @State private var isSheetPresented: Bool = false
    @State private var isFlowPresented: Bool = false

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
                    .buttonStyle(.backport(.glassProminent))
                    .controlSize(.large)
                    .scenePadding(.horizontal)
                }
            )
            .sheet(isPresented: $isFlowPresented) {
                PreviewNotificationFlow()
            }
        }
    }
}
