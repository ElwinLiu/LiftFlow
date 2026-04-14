import SwiftUI

struct ContentView: View {
    private let exercises = CanonicalExerciseCatalog.all

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("\(exercises.count) canonical exercises embedded in Swift.")
                    Text("These records are app-owned reference data, not user data.")
                        .foregroundStyle(.secondary)
                }

                Section("Catalog Preview") {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.headline)

                            Text(exercise.key)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)

                            if !exercise.aliases.isEmpty {
                                Text(exercise.aliases.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("Soft")
        }
    }
}

#Preview {
    ContentView()
}
