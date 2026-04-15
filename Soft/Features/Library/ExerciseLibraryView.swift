import SwiftUI

struct ExerciseLibraryView: View {
    @State private var groupingMode: ExerciseGroupingMode = .bodyPart

    let exercises: [CanonicalExercise]

    var body: some View {
        ScrollViewReader { scrollProxy in
            libraryContent(using: scrollProxy)
                .navigationTitle("Exercises")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func libraryContent(using scrollProxy: ScrollViewProxy) -> some View {
        ZStack {
            BackgroundCanvas()

            VStack(spacing: 12) {
                ExerciseLibraryHeader(
                    selection: $groupingMode,
                    sections: sectionModels,
                    onSelectSection: { sectionID in
                        jumpToSection(sectionID, with: scrollProxy)
                    }
                )

                mainContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if hasSections {
            sectionList
        } else {
            emptyState
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Exercises",
            systemImage: "list.bullet.rectangle",
            description: Text("This category does not have any exercises yet.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sectionList: some View {
        List {
            ForEach(sectionModels) { section in
                Section {
                    ForEach(section.exercises) { exercise in
                        CompactExerciseRow(exercise: exercise)
                            .listRowInsets(
                                EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    ExerciseSectionHeader(section: section)
                        .textCase(nil)
                        .id(section.id)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var hasSections: Bool {
        !sectionModels.isEmpty
    }

    private var sectionModels: [ExerciseSectionModel] {
        groupingMode.makeSections(from: exercises)
    }

    private func jumpToSection(_ sectionID: String, with scrollProxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.22)) {
            scrollProxy.scrollTo(sectionID, anchor: .top)
        }
    }
}

private struct ExerciseLibraryHeader: View {
    @Binding var selection: ExerciseGroupingMode
    let sections: [ExerciseSectionModel]
    let onSelectSection: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Surface(padding: 14) {
                Picker("Browse by", selection: $selection) {
                    ForEach(ExerciseGroupingMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            if !sections.isEmpty {
                SectionJumpStrip(
                    sections: sections,
                    onSelect: onSelectSection
                )
            }
        }
    }
}

private struct SectionJumpStrip: View {
    let sections: [ExerciseSectionModel]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sections) { section in
                    Button {
                        onSelect(section.id)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: section.systemImage)
                                .font(.caption.weight(.semibold))
                                .accessibilityHidden(true)

                            Text(section.title)
                                .font(.footnote.weight(.medium))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

private struct ExerciseSectionHeader: View {
    let section: ExerciseSectionModel

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: section.systemImage)
                .font(.headline)
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)

            Text(section.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.ink)

            Text(section.subtitle)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }
}

private struct CompactExerciseRow: View {
    let exercise: CanonicalExercise

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            details
            Spacer(minLength: 0)
            focusBadge
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(rowBackground)
        .overlay(rowBorder)
        .accessibilityElement(children: .combine)
    }

    private var thumbnail: some View {
        ExerciseThumbnailView(imageAssetName: exercise.imageAssetName, cornerRadius: 14)
            .frame(width: 54, height: 54)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(equipmentText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(focusText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var focusBadge: some View {
        Text(exercise.primaryFocus.name)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Theme.accent.opacity(0.14), in: Capsule())
    }

    private var equipmentText: String {
        exercise.equipment.map(\.name).joined(separator: ", ")
    }

    private var focusText: String {
        exercise.focus.map(\.name).joined(separator: " • ")
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
    }

    private var rowBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(.white.opacity(0.2), lineWidth: 1)
    }
}

private enum ExerciseGroupingMode: String, CaseIterable, Identifiable {
    case bodyPart
    case equipment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bodyPart:
            "Body Part"
        case .equipment:
            "Equipment"
        }
    }

    func makeSections(from exercises: [CanonicalExercise]) -> [ExerciseSectionModel] {
        switch self {
        case .bodyPart:
            bodyPartSections(from: exercises)
        case .equipment:
            equipmentSections(from: exercises)
        }
    }

    private func bodyPartSections(from exercises: [CanonicalExercise]) -> [ExerciseSectionModel] {
        var sections: [ExerciseSectionModel] = []

        for bodyPart in CanonicalBodyPart.allCases {
            let matches = exercises.filter { exercise in
                exercise.primaryFocus == bodyPart
            }

            guard !matches.isEmpty else { continue }
            sections.append(.bodyPart(bodyPart, exercises: matches))
        }

        return sections
    }

    private func equipmentSections(from exercises: [CanonicalExercise]) -> [ExerciseSectionModel] {
        var sections: [ExerciseSectionModel] = []

        for equipment in CanonicalEquipment.allCases {
            let matches = exercises.filter { exercise in
                exercise.equipment.contains(equipment)
            }

            guard !matches.isEmpty else { continue }
            sections.append(.equipment(equipment, exercises: matches))
        }

        return sections
    }
}

private struct ExerciseSectionModel: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let exercises: [CanonicalExercise]
}

private extension ExerciseSectionModel {
    static func bodyPart(_ bodyPart: CanonicalBodyPart, exercises: [CanonicalExercise]) -> Self {
        Self(
            id: "body-\(bodyPart.id)",
            title: bodyPart.name,
            subtitle: "\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")",
            systemImage: bodyPart.librarySystemImage,
            exercises: exercises
        )
    }

    static func equipment(_ equipment: CanonicalEquipment, exercises: [CanonicalExercise]) -> Self {
        Self(
            id: "equipment-\(equipment.id)",
            title: equipment.name,
            subtitle: "\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")",
            systemImage: equipment.librarySystemImage,
            exercises: exercises
        )
    }
}

private extension CanonicalBodyPart {
    var librarySystemImage: String {
        switch self {
        case .back:
            "figure.walk.motion"
        case .biceps:
            "figure.strengthtraining.functional"
        case .calves:
            "figure.run"
        case .chest:
            "heart.text.square.fill"
        case .core:
            "scope"
        case .forearms:
            "hand.raised.fill"
        case .glutes:
            "figure.stand"
        case .hamstrings:
            "bolt.heart.fill"
        case .quads:
            "figure.step.training"
        case .shoulders:
            "figure.arms.open"
        case .triceps:
            "figure.cooldown"
        }
    }

}

private extension CanonicalEquipment {
    var librarySystemImage: String {
        switch self {
        case .barbell:
            "dumbbell.fill"
        case .bench, .inclineBench:
            "bed.double.fill"
        case .bodyweight:
            "figure.strengthtraining.traditional"
        case .cable, .ropeAttachment:
            "point.3.connected.trianglepath.dotted"
        case .dipBars, .pullUpBar, .rack:
            "square.split.2x2"
        case .dumbbell, .kettlebell:
            "dumbbell"
        case .machine:
            "gearshape.2.fill"
        }
    }

}
