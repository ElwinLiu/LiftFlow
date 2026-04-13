import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Hello, world!")
                    .font(.largeTitle.weight(.bold))
                Text("LiftFlow frontend stub")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("LiftFlow")
        }
    }
}

#Preview {
    ContentView()
}
