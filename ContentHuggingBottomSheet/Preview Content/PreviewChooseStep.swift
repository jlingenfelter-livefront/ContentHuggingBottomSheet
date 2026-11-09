import SwiftUI

struct PreviewChooseStep: View {
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

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var selection: Set<PreviewNotification> = [.classReminders, .waitlistUpdates]

    Button("Show Sheet!") {
        isPresented = true
    }
    .adaptiveBottomSheet(isPresented: $isPresented) {
        PreviewChooseStep(selection: $selection)
            .navigationTitle("Choose Notifications")
    }
}
