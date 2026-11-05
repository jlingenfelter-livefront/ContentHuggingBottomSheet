import SwiftUI
import Playgrounds

struct ContentView: View {
    @State var isPresented: Bool = false
    @State private var isExpanded: Bool = false

    var body: some View {
        Button("Press me") {
            isPresented = true
        }
        .adaptiveBottomSheet(
            isPresented: $isPresented,
            content: {
                VStack(spacing: 0) {
                    Color.orange.frame(height: 100)
                    Button(isExpanded ? "Collapse" : "Expand") {
                        isExpanded.toggle()
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    Color.blue.frame(height: isExpanded ? 400 : 200)
                    Color.purple.frame(height: 50)
                }
                .animation(.snappy, value: isExpanded)
                .navigationTitle("Sheet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button("", systemImage: "star") {
                            isPresented = false
                        }
                    }
                }
            },
            footer: {
                Button("Hello") {
                    isPresented = false
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(.indigo)
                .clipShape(Capsule())
                .scenePadding(.horizontal)
            }
        )
    }
}

#Preview {
    ContentView()
}
