import SwiftUI

@main struct MyApp: App {
    @State private var isPresented: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Button("Show Sheet!") {
                isPresented = true
            }
            .adaptiveBottomSheet(
                isPresented: $isPresented,
                content: { PreviewSheetContent() },
                footer: {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Turn On")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .scenePadding(.horizontal)
                }
            )
        }
    }
}
