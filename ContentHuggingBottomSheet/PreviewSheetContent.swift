import SwiftUI

struct PreviewSheetContent: View {
    @Binding var isPresented: Bool
    @State private var showsDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Turn on notifications", systemImage: "bell.badge.fill")
                .font(.title2.bold())

            Text("Get a heads-up when your class is about to start or a spot opens up.")
                .foregroundStyle(.secondary)

            // Toggling this resizes the content, so the sheet animates to fit
            DisclosureGroup("What we'll send", isExpanded: $showsDetails) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Class reminders", systemImage: "calendar")
                    Label("Waitlist updates", systemImage: "person.2")
                    Label("Schedule changes", systemImage: "arrow.triangle.2.circlepath")
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .animation(.snappy, value: showsDetails)
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark") {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true

    Button("Show Sheet!") {
        isPresented = true
    }
    .adaptiveBottomSheet(
        isPresented: $isPresented,
        content: { PreviewSheetContent(isPresented: $isPresented) },
        footer: {
            Button {
                isPresented = false
            } label: {
                Text("Turn On")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .scenePadding()
        }
    )
}
