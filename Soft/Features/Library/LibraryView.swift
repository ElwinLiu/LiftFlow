import SwiftUI

struct LibraryView: View {
    private let exercises = CanonicalExerciseCatalog.all

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundCanvas()

                ScrollView {
                    VStack(spacing: 18) {
                        Surface {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Library")
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                                Text("Build your catalog one collection at a time. Start with exercises, then expand into new movement libraries.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 10) {
                                    DetailChip(title: "\(exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                                    DetailChip(title: "Curated", systemImage: "checkmark.seal.fill")
                                }
                            }
                        }

                        NavigationLink {
                            ExerciseLibraryView(exercises: exercises)
                        } label: {
                            ExerciseLibraryCard(exerciseCount: exercises.count)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens the exercise library")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Library")
        }
    }
}

private struct ExerciseLibraryCard: View {
    let exerciseCount: Int

    var body: some View {
        Surface {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    ExerciseThumbnailView(imageAssetName: nil, cornerRadius: 20)
                        .frame(width: 96, height: 104)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Exercise Library")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text("Browse the canonical movement reference library with a stronger card layout built for future artwork.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            DetailChip(title: "\(exerciseCount) entries", systemImage: "list.bullet.rectangle.fill")
                            DetailChip(title: "Placeholder art", systemImage: "photo.fill")
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.up.right")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(.white.opacity(0.18), in: Circle())
                        .accessibilityHidden(true)
                }

                Text("Strength movements, machine work, bodyweight drills, and the metadata you’ll eventually pair with generated imagery.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
