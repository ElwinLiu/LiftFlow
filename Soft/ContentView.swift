import SwiftUI

struct ContentView: View {
    private let exercises = CanonicalExerciseCatalog.all
    private let bodyParts = CanonicalBodyPart.allCases
    private let equipment = CanonicalEquipment.allCases

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("\(exercises.count) canonical exercises embedded in Swift.")
                    Text("These records are app-owned reference data, not user data.")
                        .foregroundStyle(.secondary)
                }

                Section("Reference Catalogs") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(bodyParts.count) canonical body parts")
                            .font(.subheadline.weight(.medium))
                        Text(bodyParts.map(\.name).joined(separator: ", "))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(equipment.count) canonical equipment records")
                            .font(.subheadline.weight(.medium))
                        Text(equipment.map(\.name).joined(separator: ", "))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }

                Section("Catalog Preview") {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.headline)

                            Text(exercise.key)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)

                            Text("Primary focus: \(exercise.primaryFocus.name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("Focus: \(exercise.focus.map(\.name).joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if exercise.focus.count > 1 {
                                Text("Additional focus: \(exercise.focus.dropFirst().map(\.name).joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Text("Equipment: \(exercise.equipment.map(\.name).joined(separator: ", "))")
                                .font(.subheadline)
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
