import SwiftUI

struct PreviewIntroStep: View {
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

#Preview {
    @Previewable @State var isPresented = true

    Button("Show Sheet!") {
        isPresented = true
    }
    .adaptiveBottomSheet(isPresented: $isPresented) {
        PreviewIntroStep()
            .navigationTitle("Notifications")
    }
}
