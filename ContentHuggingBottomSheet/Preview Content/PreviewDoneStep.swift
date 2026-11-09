import SwiftUI

struct PreviewDoneStep: View {
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
    @Previewable @State var isPresented = true

    Button("Show Sheet!") {
        isPresented = true
    }
    .adaptiveBottomSheet(isPresented: $isPresented) {
        PreviewDoneStep(selection: [.classReminders, .waitlistUpdates])
    }
}
