import SwiftUI

private enum SectionSelectionSource {
    case timeline
    case list
    case sync
}

private enum ExerciseLibraryMetrics {
    static let headerSpacing: CGFloat = 8
    static let headerTopPadding: CGFloat = 8
    static let headerRowSpacing: CGFloat = 10
    static let listSectionSpacing: CGFloat = 12
    static let listHorizontalPadding: CGFloat = 14
    static let listBottomPadding: CGFloat = 18

    static let sectionHeaderHorizontalPadding: CGFloat = 16
    static let sectionHeaderVerticalPadding: CGFloat = 8
    static let sectionHeaderSpacing: CGFloat = 8
    static let sectionCardCornerRadius: CGFloat = 18

    static let rowHorizontalPadding: CGFloat = 14
    static let rowVerticalPadding: CGFloat = 8
    static let rowContentSpacing: CGFloat = 10
    static let rowThumbnailSize: CGFloat = 48
    static let rowThumbnailCornerRadius: CGFloat = 12
    static let rowDetailSpacing: CGFloat = 2
    static let rowBadgeHorizontalPadding: CGFloat = 7
    static let rowBadgeVerticalPadding: CGFloat = 3

    static let jumpStripSpacing: CGFloat = 8
    static let jumpStripHorizontalPadding: CGFloat = 16
    static let jumpStripVerticalPadding: CGFloat = 4
    static let jumpStripHeight: CGFloat = 72
    static let jumpNodeSpacing: CGFloat = 6
    static let jumpNodeIndicatorSize: CGFloat = 7
    static let groupingMenuButtonSize: CGFloat = 42
    static let groupingMenuCornerRadius: CGFloat = 14

    static var rowDividerLeadingInset: CGFloat {
        rowHorizontalPadding + rowThumbnailSize + rowContentSpacing
    }
}

struct ExerciseLibraryView: View {
    @State private var groupingMode: ExerciseGroupingMode = .bodyPart
    @State private var selectedSectionID: String?
    @State private var selectionSource: SectionSelectionSource = .sync
    @State private var selectionFeedbackTrigger = false
    @State private var suppressListSelectionUpdates = false
    @State private var listSelectionSuppressionToken = 0

    let exercises: [CanonicalExercise]

    var body: some View {
        ScrollViewReader { scrollProxy in
            libraryContent
                .navigationTitle("Exercises")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: sectionIDs, initial: true) { _, sectionIDs in
                    guard let firstSectionID = sectionIDs.first else {
                        selectionSource = .sync
                        selectedSectionID = nil
                        return
                    }

                    guard let selectedSectionID, sectionIDs.contains(selectedSectionID) else {
                        selectionSource = .sync
                        self.selectedSectionID = firstSectionID
                        return
                    }
                }
                .onChange(of: selectedSectionID) { oldSectionID, newSectionID in
                    guard let newSectionID, oldSectionID != newSectionID else { return }

                    if selectionSource == .timeline, oldSectionID != nil {
                        selectionFeedbackTrigger.toggle()
                    }

                    if selectionSource == .timeline {
                        suppressListSelectionUpdates = true
                        listSelectionSuppressionToken += 1
                        let suppressionToken = listSelectionSuppressionToken

                        jumpToSection(newSectionID, with: scrollProxy)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            guard suppressionToken == listSelectionSuppressionToken else { return }
                            suppressListSelectionUpdates = false
                        }
                    }

                    selectionSource = .sync
                }
                .sensoryFeedback(.selection, trigger: selectionFeedbackTrigger)
        }
    }

    private var libraryContent: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: ExerciseLibraryMetrics.headerSpacing) {
                ExerciseLibraryHeader(
                    selection: $groupingMode,
                    sections: sectionModels,
                    selectedSectionID: selectedSectionID,
                    onSelectSection: { sectionID in
                        guard selectedSectionID != sectionID else { return }
                        selectionSource = .timeline
                        selectedSectionID = sectionID
                    }
                )

                mainContent
            }
            .padding(.top, ExerciseLibraryMetrics.headerTopPadding)
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
        ScrollView {
            LazyVStack(spacing: ExerciseLibraryMetrics.listSectionSpacing, pinnedViews: [.sectionHeaders]) {
                ForEach(sectionModels) { section in
                    ExerciseLibrarySection(
                        section: section,
                        scrollTargetID: scrollTargetID(for: section.id)
                    )
                }
            }
            .padding(.horizontal, ExerciseLibraryMetrics.listHorizontalPadding)
            .padding(.bottom, ExerciseLibraryMetrics.listBottomPadding)
        }
        .coordinateSpace(.named("ExerciseLibrarySectionScroll"))
        .onPreferenceChange(ExerciseLibrarySectionOffsetPreferenceKey.self) { offsets in
            updateVisibleSection(using: offsets)
        }
        .background(Color(.systemGroupedBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var hasSections: Bool {
        !sectionModels.isEmpty
    }

    private var sectionModels: [ExerciseSectionModel] {
        groupingMode.makeSections(from: exercises)
    }

    private var sectionIDs: [String] {
        sectionModels.map(\.id)
    }

    private func updateVisibleSection(using offsets: [String: CGFloat]) {
        guard suppressListSelectionUpdates == false else { return }

        let orderedOffsets = sectionIDs.compactMap { sectionID in
            offsets[sectionID].map { (sectionID, $0) }
        }

        guard orderedOffsets.isEmpty == false else { return }

        let threshold: CGFloat = 16
        let resolvedSectionID: String

        if let currentSectionID = orderedOffsets
            .filter({ $0.1 <= threshold })
            .max(by: { $0.1 < $1.1 })?
            .0 {
            resolvedSectionID = currentSectionID
        } else if let nearestSectionID = orderedOffsets.min(by: { $0.1 < $1.1 })?.0 {
            resolvedSectionID = nearestSectionID
        } else {
            return
        }

        guard selectedSectionID != resolvedSectionID else { return }
        selectionSource = .list
        selectedSectionID = resolvedSectionID
    }

    private func jumpToSection(_ sectionID: String, with scrollProxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.22)) {
            scrollProxy.scrollTo(scrollTargetID(for: sectionID), anchor: .top)
        }
    }

    private func scrollTargetID(for sectionID: String) -> String {
        "exercise-library-target-\(sectionID)"
    }
}

private struct ExerciseLibrarySection: View {
    let section: ExerciseSectionModel
    let scrollTargetID: String

    var body: some View {
        Section {
            VStack(spacing: 0) {
                ForEach(Array(section.exercises.enumerated()), id: \.element.id) { index, exercise in
                    CompactExerciseRow(exercise: exercise)
                        .padding(.horizontal, ExerciseLibraryMetrics.rowHorizontalPadding)
                        .padding(.vertical, ExerciseLibraryMetrics.rowVerticalPadding)

                    if index < section.exercises.count - 1 {
                        Divider()
                            .padding(.leading, ExerciseLibraryMetrics.rowDividerLeadingInset)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: ExerciseLibraryMetrics.sectionCardCornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        } header: {
            ExerciseSectionHeader(section: section)
                .id(scrollTargetID)
                .padding(.horizontal, ExerciseLibraryMetrics.sectionHeaderHorizontalPadding)
                .padding(.vertical, ExerciseLibraryMetrics.sectionHeaderVerticalPadding)
                .background(Color(.systemGroupedBackground))
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ExerciseLibrarySectionOffsetPreferenceKey.self,
                            value: [section.id: proxy.frame(in: .named("ExerciseLibrarySectionScroll")).minY]
                        )
                    }
                }
                .textCase(nil)
        }
    }
}

private struct ExerciseLibrarySectionOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]

    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}

private struct ExerciseLibraryHeader: View {
    @Binding var selection: ExerciseGroupingMode
    let sections: [ExerciseSectionModel]
    let selectedSectionID: String?
    let onSelectSection: (String) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: ExerciseLibraryMetrics.headerRowSpacing) {
            ExerciseGroupingMenu(selection: $selection)

            if !sections.isEmpty {
                SectionJumpStrip(
                    sections: sections,
                    selectedSectionID: selectedSectionID,
                    onSelectSection: onSelectSection
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, ExerciseLibraryMetrics.jumpStripHorizontalPadding)
    }
}

private struct SectionJumpStrip: View {
    let sections: [ExerciseSectionModel]
    let selectedSectionID: String?
    let onSelectSection: (String) -> Void
    @State private var settledIndex = 0
    @State private var highlightedIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let itemWidth = sectionItemWidth(for: geometry.size.width)
            let centeredOffset = centeredOffset(
                for: settledIndex,
                containerWidth: geometry.size.width,
                itemWidth: itemWidth
            )
            let resolvedOffset = clampedOffset(
                centeredOffset + dragOffset,
                containerWidth: geometry.size.width,
                itemWidth: itemWidth
            )
            let dragGesture = DragGesture(minimumDistance: 4)
                .onChanged { value in
                    isDragging = true

                    let clamped = clampedOffset(
                        centeredOffset + value.translation.width,
                        containerWidth: geometry.size.width,
                        itemWidth: itemWidth
                    )
                    dragOffset = clamped - centeredOffset

                    let nearestIndex = nearestIndex(
                        for: clamped,
                        containerWidth: geometry.size.width,
                        itemWidth: itemWidth
                    )

                    guard nearestIndex != highlightedIndex else { return }
                    highlightedIndex = nearestIndex
                }
                .onEnded { value in
                    let clamped = clampedOffset(
                        centeredOffset + value.translation.width,
                        containerWidth: geometry.size.width,
                        itemWidth: itemWidth
                    )
                    let nearestIndex = nearestIndex(
                        for: clamped,
                        containerWidth: geometry.size.width,
                        itemWidth: itemWidth
                    )
                    guard let sectionID = sectionID(at: nearestIndex) else {
                        isDragging = false
                        dragOffset = 0
                        return
                    }

                    isDragging = false
                    highlightedIndex = nearestIndex

                    withAnimation(.easeInOut(duration: 0.22)) {
                        settledIndex = nearestIndex
                        dragOffset = 0
                    }

                    if selectedSectionID != sectionID {
                        onSelectSection(sectionID)
                    }
                }

            ZStack {
                HStack(spacing: 0) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        let isSelected = highlightedIndex == index

                        Button {
                            guard isDragging == false else { return }
                            selectSection(at: index)
                        } label: {
                            TimelineNode(
                                section: section,
                                isSelected: isSelected,
                                showsLeadingConnector: index > 0,
                                showsTrailingConnector: index < sections.count - 1
                            )
                            .frame(width: itemWidth)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, ExerciseLibraryMetrics.jumpStripVerticalPadding)
                .offset(x: resolvedOffset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .onChange(of: sectionIDs, initial: true) { _, sectionIDs in
                    guard let firstSectionID = sectionIDs.first else {
                        settledIndex = 0
                        highlightedIndex = 0
                        dragOffset = 0
                        return
                    }

                    let resolvedSectionID = if let selectedSectionID,
                                               let _ = sectionIDs.firstIndex(of: selectedSectionID) {
                        selectedSectionID
                    } else {
                        firstSectionID
                    }

                    guard let resolvedIndex = sectionIDs.firstIndex(of: resolvedSectionID) else { return }

                    settledIndex = resolvedIndex
                    highlightedIndex = resolvedIndex
                    dragOffset = 0
                }
                .onChange(of: selectedSectionID) { _, newSectionID in
                    guard
                        isDragging == false,
                        let newSectionID,
                        let newIndex = sectionIDs.firstIndex(of: newSectionID),
                        newIndex != settledIndex || highlightedIndex != newIndex
                    else {
                        return
                    }

                    withAnimation(.easeInOut(duration: 0.22)) {
                        settledIndex = newIndex
                        highlightedIndex = newIndex
                        dragOffset = 0
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .highPriorityGesture(dragGesture, including: .all)

            }
        }
        .frame(height: ExerciseLibraryMetrics.jumpStripHeight)
    }

    private var sectionIDs: [String] {
        sections.map(\.id)
    }

    private func sectionID(at index: Int) -> String? {
        guard sections.indices.contains(index) else { return nil }
        return sections[index].id
    }

    private func selectSection(at index: Int) {
        guard let sectionID = sectionID(at: index) else { return }

        isDragging = false
        highlightedIndex = index

        withAnimation(.easeInOut(duration: 0.22)) {
            settledIndex = index
            dragOffset = 0
        }

        if selectedSectionID != sectionID {
            onSelectSection(sectionID)
        }
    }

    private func centeredOffset(
        for index: Int,
        containerWidth: CGFloat,
        itemWidth: CGFloat
    ) -> CGFloat {
        (containerWidth / 2) - (itemWidth / 2) - (CGFloat(index) * itemWidth)
    }

    private func clampedOffset(
        _ proposedOffset: CGFloat,
        containerWidth: CGFloat,
        itemWidth: CGFloat
    ) -> CGFloat {
        let minimum = centeredOffset(
            for: max(sections.count - 1, 0),
            containerWidth: containerWidth,
            itemWidth: itemWidth
        )
        let maximum = centeredOffset(
            for: 0,
            containerWidth: containerWidth,
            itemWidth: itemWidth
        )

        return min(max(proposedOffset, minimum), maximum)
    }

    private func nearestIndex(
        for offset: CGFloat,
        containerWidth: CGFloat,
        itemWidth: CGFloat
    ) -> Int {
        let rawIndex = ((containerWidth / 2) - (itemWidth / 2) - offset) / itemWidth
        let roundedIndex = Int(rawIndex.rounded())
        return min(max(roundedIndex, 0), max(sections.count - 1, 0))
    }

    private func sectionItemWidth(for availableWidth: CGFloat) -> CGFloat {
        min(78, max(60, availableWidth * 0.17))
    }
}

private struct TimelineNode: View {
    let section: ExerciseSectionModel
    let isSelected: Bool
    let showsLeadingConnector: Bool
    let showsTrailingConnector: Bool

    var body: some View {
        VStack(spacing: ExerciseLibraryMetrics.jumpNodeSpacing) {
            HStack(spacing: 0) {
                connector(visible: showsLeadingConnector)

                Circle()
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.28))
                    .frame(
                        width: ExerciseLibraryMetrics.jumpNodeIndicatorSize,
                        height: ExerciseLibraryMetrics.jumpNodeIndicatorSize
                    )
                    .overlay {
                        Circle()
                            .stroke(Color(.systemGroupedBackground), lineWidth: 2)
                    }

                connector(visible: showsTrailingConnector)
            }

            Text(section.title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(section.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func connector(visible: Bool) -> some View {
        if visible {
            Capsule()
                .fill(Color.secondary.opacity(isSelected ? 0.28 : 0.14))
                .frame(maxWidth: .infinity)
                .frame(height: 2)
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 2)
        }
    }
}

private struct ExerciseGroupingMenu: View {
    @Binding var selection: ExerciseGroupingMode

    var body: some View {
        Menu {
            ForEach(ExerciseGroupingMode.allCases) { mode in
                Button {
                    selection = mode
                } label: {
                    Label(mode.title, systemImage: mode.menuSystemImage)
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(
                    width: ExerciseLibraryMetrics.groupingMenuButtonSize,
                    height: ExerciseLibraryMetrics.groupingMenuButtonSize
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: ExerciseLibraryMetrics.groupingMenuCornerRadius,
                        style: .continuous
                    )
                    .fill(Color(.secondarySystemGroupedBackground))
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: ExerciseLibraryMetrics.groupingMenuCornerRadius,
                        style: .continuous
                    )
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                }
        }
        .accessibilityLabel("Choose exercise grouping")
        .accessibilityValue(selection.title)
        .accessibilityHint("Switch between body part and equipment categories")
    }
}

private struct ExerciseSectionHeader: View {
    let section: ExerciseSectionModel

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ExerciseLibraryMetrics.sectionHeaderSpacing) {
            Image(systemName: section.systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(section.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(section.subtitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 2)
    }
}

private struct CompactExerciseRow: View {
    let exercise: CanonicalExercise

    var body: some View {
        HStack(spacing: ExerciseLibraryMetrics.rowContentSpacing) {
            thumbnail
            details
            Spacer(minLength: 0)
            focusBadge
        }
        .accessibilityElement(children: .combine)
    }

    private var thumbnail: some View {
        ExerciseThumbnailView(
            imageAssetName: exercise.imageAssetName,
            cornerRadius: ExerciseLibraryMetrics.rowThumbnailCornerRadius
        )
        .frame(
            width: ExerciseLibraryMetrics.rowThumbnailSize,
            height: ExerciseLibraryMetrics.rowThumbnailSize
        )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: ExerciseLibraryMetrics.rowDetailSpacing) {
            Text(exercise.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(equipmentText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            focusText
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var focusBadge: some View {
        Text(exercise.primaryFocus.name)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, ExerciseLibraryMetrics.rowBadgeHorizontalPadding)
            .padding(.vertical, ExerciseLibraryMetrics.rowBadgeVerticalPadding)
            .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
    }

    private var equipmentText: String {
        exercise.equipment.map(\.name).joined(separator: ", ")
    }

    private var focusText: Text {
        guard let primary = exercise.focus.first else {
            return Text("")
        }

        return exercise.focus.dropFirst().reduce(Text(primary.name).bold()) { partialText, bodyPart in
            partialText + Text(" • ") + Text(bodyPart.name)
        }
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

    var menuSystemImage: String {
        switch self {
        case .bodyPart:
            "figure.strengthtraining.traditional"
        case .equipment:
            "dumbbell"
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
