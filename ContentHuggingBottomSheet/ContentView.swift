import SwiftUI
import Playgrounds

struct ContentView: View {
    @State var isPresented: Bool = false

    var body: some View {
        Button("Press me") {
            isPresented = true
        }
        .contentHuggingBottomSheet(
            isPresented: $isPresented,
            content: {
                VStack(spacing: 0) {
                    Color.orange.frame(height: 100)
                    Color.blue.frame(height: 400)
                    Color.purple.frame(height: 40)
                }
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
                .background(Color.mint)
            }
        )
    }
}

#Preview {
    ContentView()
}
