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
                VStack {
                    Color.orange.frame(height: 100)
                    Color.blue.frame(height: 400)
                    Color.purple.frame(height: 40)
                }
                .navigationTitle("Sheet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button("", systemImage: "star") {

                        }
                    }
                }
            },
            footer: {
                Button("Hello") {

                }
                .background(.indigo)
            }
        )
    }
}

#Preview {
    ContentView()
}
