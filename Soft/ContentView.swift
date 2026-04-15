import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            LibraryTabView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
        .tint(SoftTheme.accent)
    }
}

#Preview {
    ContentView()
}

private struct HomeTabView: View {
    @State private var heroVisible = false

    private let exercises = CanonicalExerciseCatalog.all
    private let bodyParts = CanonicalBodyPart.allCases
    private let equipment = CanonicalEquipment.allCases

    var body: some View {
        NavigationStack {
            homeContent
        }
    }

    private var homeContent: some View {
        ZStack {
            SoftCanvas()

            ScrollView {
                VStack(spacing: 18) {
                    HomeHeroCard(
                        exerciseCount: exercises.count,
                        primaryBodyPart: primaryBodyPartName,
                        isVisible: heroVisible
                    )

                    metricsSection
                    readyCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Home")
        .onAppear(perform: revealHero)
    }

    private var primaryBodyPartName: String {
        exercises.first?.primaryFocus.name ?? "Full Body"
    }

    private var metricsSection: some View {
        HStack(spacing: 14) {
            MetricCard(
                title: "Body Map",
                value: "\(bodyParts.count)",
                detail: "focus zones"
            )

            MetricCard(
                title: "Equipment",
                value: "\(equipment.count)",
                detail: "gear profiles"
            )
        }
    }

    private var readyCard: some View {
        SoftSurface {
            VStack(alignment: .leading, spacing: 14) {
                Label("What’s Ready", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SoftTheme.accent)

                Text("A cleaner exercise reference flow")
                    .font(.title3.weight(.semibold))

                Text("Open the Library tab to browse exercise cards with stronger hierarchy, placeholder imagery, and at-a-glance metadata.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    DetailChip(title: "Library", systemImage: "books.vertical.fill")
                    DetailChip(title: "Exercise cards", systemImage: "square.grid.2x2.fill")
                }
            }
        }
    }

    private func revealHero() {
        withAnimation(.easeOut(duration: 0.7)) {
            heroVisible = true
        }
    }
}

private struct LibraryTabView: View {
    private let exercises = CanonicalExerciseCatalog.all

    var body: some View {
        NavigationStack {
            ZStack {
                SoftCanvas()

                ScrollView {
                    VStack(spacing: 18) {
                        SoftSurface {
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
        SoftSurface {
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

private struct ExerciseLibraryView: View {
    @State private var groupingMode: ExerciseGroupingMode = .bodyPart
    @State private var focusedSectionID: String?
    @State private var sectionMinYByID: [String: CGFloat] = [:]

    let exercises: [CanonicalExercise]

    var body: some View {
        ScrollViewReader { scrollProxy in
            libraryContent(using: scrollProxy)
        }
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: sectionIDs, initial: true) {
            syncFocusedSection()
        }
        .sensoryFeedback(.selection, trigger: focusedSectionID)
    }

    private func libraryContent(using scrollProxy: ScrollViewProxy) -> some View {
        ZStack(alignment: .trailing) {
            SoftCanvas()

            VStack(spacing: 12) {
                ExerciseLibraryHeader(
                    groupingMode: groupingMode,
                    focusedSection: focusedSection,
                    selection: $groupingMode
                )

                mainContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)

            if hasSections {
                indexRail(using: scrollProxy)
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if hasSections {
            sectionScrollView
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

    private var sectionScrollView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(sectionModels) { section in
                    ExerciseSectionBlock(section: section)
                        .id(section.id)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.frame(in: .named("exercise-library-scroll")).minY
                        } action: { newValue in
                            updateSectionPosition(sectionID: section.id, minY: newValue)
                        }
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 20)
            .padding(.trailing, 20)
        }
        .coordinateSpace(.named("exercise-library-scroll"))
    }

    private func indexRail(using scrollProxy: ScrollViewProxy) -> some View {
        FloatingStringIndexRail(
            categories: sectionModels,
            focusedSectionID: focusedSectionID,
            onSelect: { sectionID in
                jumpToSection(sectionID, with: scrollProxy)
            }
        )
        .padding(.trailing, 10)
        .padding(.top, 118)
        .padding(.bottom, 24)
    }

    private var hasSections: Bool {
        !sectionModels.isEmpty
    }

    private var sectionIDs: [String] {
        sectionModels.map(\.id)
    }

    private var sectionModels: [ExerciseSectionModel] {
        groupingMode.makeSections(from: exercises)
    }

    private var focusedSection: ExerciseSectionModel? {
        let models = sectionModels
        guard !models.isEmpty else { return nil }

        if let focusedSectionID,
           let exactMatch = models.first(where: { $0.id == focusedSectionID }) {
            return exactMatch
        }

        return models.first
    }

    private func syncFocusedSection() {
        let models = sectionModels

        guard !models.isEmpty else {
            focusedSectionID = nil
            sectionMinYByID = [:]
            return
        }

        let validIDs = Set(models.map(\.id))
        sectionMinYByID = sectionMinYByID.filter { validIDs.contains($0.key) }

        if let focusedSectionID,
           models.contains(where: { $0.id == focusedSectionID }) {
            return
        }

        focusedSectionID = models.first?.id
    }

    private func updateSectionPosition(sectionID: String, minY: CGFloat) {
        sectionMinYByID[sectionID] = minY
        refreshFocusedSection()
    }

    private func refreshFocusedSection() {
        let threshold: CGFloat = 136
        let positionedSections = sectionModels.compactMap { section -> (String, CGFloat)? in
            guard let minY = sectionMinYByID[section.id] else { return nil }
            return (section.id, minY)
        }

        guard !positionedSections.isEmpty else { return }

        if let current = positionedSections
            .filter({ $0.1 <= threshold })
            .max(by: { $0.1 < $1.1 }) {
            focusedSectionID = current.0
            return
        }

        focusedSectionID = positionedSections
            .min(by: { abs($0.1 - threshold) < abs($1.1 - threshold) })?
            .0
    }

    private func jumpToSection(_ sectionID: String, with scrollProxy: ScrollViewProxy) {
        focusedSectionID = sectionID
        withAnimation(.easeInOut(duration: 0.22)) {
            scrollProxy.scrollTo(sectionID, anchor: .top)
        }
    }
}

private struct ExerciseSectionBlock: View {
    let section: ExerciseSectionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ExerciseSectionHeader(section: section)

            LazyVStack(spacing: 10) {
                ForEach(section.exercises) { exercise in
                    CompactExerciseRow(exercise: exercise)
                }
            }
        }
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
            .foregroundStyle(SoftTheme.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(SoftTheme.accent.opacity(0.14), in: Capsule())
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

private struct ExerciseThumbnailView: View {
    let imageAssetName: String?
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SoftTheme.ink,
                            SoftTheme.accent,
                            SoftTheme.warm
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.white.opacity(0.08))
                .padding(6)

            if let imageAssetName {
                Image(imageAssetName)
                    .resizable()
                    .scaledToFill()
                    .clipShape(.rect(cornerRadius: cornerRadius))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)

                    Text("Preview")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct HomeHeroCard: View {
    let exerciseCount: Int
    let primaryBodyPart: String
    let isVisible: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SoftTheme.ink,
                            SoftTheme.accent,
                            SoftTheme.warm
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 160, height: 160)
                .blur(radius: 2)
                .offset(x: 44, y: -42)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.8)
                .animation(.easeOut(duration: 0.7), value: isVisible)

            Circle()
                .fill(SoftTheme.warm.opacity(0.28))
                .frame(width: 110, height: 110)
                .blur(radius: 8)
                .offset(x: -22, y: 86)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.8)
                .animation(.easeOut(duration: 0.85), value: isVisible)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Soft")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))

                        Text("A clearer way to browse exercise knowledge.")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("The foundation is now tabbed, card-driven, and ready for richer artwork per exercise.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .rotationEffect(.degrees(isVisible ? 0 : -10))
                        .offset(y: isVisible ? 0 : -8)
                        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: isVisible)
                        .accessibilityHidden(true)
                }

                HStack(spacing: 10) {
                    DetailChip(title: "\(exerciseCount) exercises", systemImage: "books.vertical.fill", style: .inverted)
                    DetailChip(title: "Lead focus: \(primaryBodyPart)", systemImage: "sparkles", style: .inverted)
                }
            }
            .padding(24)
        }
        .shadow(color: SoftTheme.ink.opacity(0.18), radius: 18, y: 10)
    }
}

private struct ExerciseLibraryHeader: View {
    let groupingMode: ExerciseGroupingMode
    let focusedSection: ExerciseSectionModel?
    @Binding var selection: ExerciseGroupingMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SoftSurface(padding: 14) {
                Picker("Browse by", selection: $selection) {
                    ForEach(ExerciseGroupingMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            if let focusedSection {
                HStack(spacing: 10) {
                    Image(systemName: focusedSection.systemImage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SoftTheme.accent)
                        .accessibilityHidden(true)

                    Text("Current section: \(focusedSection.title)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct ExerciseSectionHeader: View {
    let section: ExerciseSectionModel

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: section.systemImage)
                .font(.headline)
                .foregroundStyle(SoftTheme.accent)
                .accessibilityHidden(true)

            Text(section.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(SoftTheme.ink)

            Text(section.subtitle)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }
}

private struct FloatingStringIndexRail: View {
    let categories: [ExerciseSectionModel]
    let focusedSectionID: String?
    let onSelect: (String) -> Void

    private let itemSpacing: CGFloat = 10
    private let verticalPadding: CGFloat = 12

    var body: some View {
        railNodes
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 6)
            .background(railBackground)
            .overlay(railBorder)
            .overlay(railSelectionTrack)
            .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .fixedSize()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Section index")
            .accessibilityValue(currentAccessibilityValue)
            .accessibilityHint("Swipe up or down to jump between sections")
            .accessibilityAdjustableAction { direction in
                adjustSelection(direction: direction)
            }
    }

    private var railNodes: some View {
        VStack(spacing: itemSpacing) {
            ForEach(categories) { category in
                IndexRailButton(
                    category: category,
                    isFocused: focusedSectionID == category.id,
                    onSelect: onSelect
                )
            }
        }
    }

    private var railBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
    }

    private var railBorder: some View {
        Capsule()
            .stroke(.white.opacity(0.24), lineWidth: 1)
    }

    private var railSelectionTrack: some View {
        Capsule()
            .fill(.white.opacity(0.18))
            .frame(width: 2)
            .padding(.vertical, 12)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                updateSelection(at: value.location)
            }
    }

    private func updateSelection(at location: CGPoint) {
        let segment: CGFloat = 36
        let effectiveY = max(location.y - verticalPadding, 0)
        let rawIndex = Int(round(effectiveY / segment))
        let clampedIndex = min(max(rawIndex, 0), categories.count - 1)
        guard categories.indices.contains(clampedIndex) else { return }

        onSelect(categories[clampedIndex].id)
    }

    private func adjustSelection(direction: AccessibilityAdjustmentDirection) {
        guard !categories.isEmpty else { return }

        let currentIndex = categories.firstIndex(where: { $0.id == focusedSectionID }) ?? 0
        let nextIndex: Int

        switch direction {
        case .increment:
            nextIndex = min(currentIndex + 1, categories.count - 1)
        case .decrement:
            nextIndex = max(currentIndex - 1, 0)
        @unknown default:
            nextIndex = currentIndex
        }

        onSelect(categories[nextIndex].id)
    }

    private var currentAccessibilityValue: String {
        categories.first(where: { $0.id == focusedSectionID })?.title ?? "None"
    }
}

private struct IndexRailButton: View {
    let category: ExerciseSectionModel
    let isFocused: Bool
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(category.id)
        } label: {
            IndexStringNode(
                label: category.indexLabel,
                isFocused: isFocused
            )
        }
        .buttonStyle(.plain)
        .accessibilityHidden(true)
    }
}

private struct IndexStringNode: View {
    let label: String
    let isFocused: Bool

    var body: some View {
        Text(label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(isFocused ? .white : SoftTheme.ink)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(backgroundStyle)
            }
            .overlay(
                Circle()
                    .fill(isFocused ? SoftTheme.accent : SoftTheme.ink.opacity(0.16))
                    .frame(width: 6, height: 6)
            )
    }

    private var backgroundStyle: AnyShapeStyle {
        if isFocused {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [SoftTheme.ink, SoftTheme.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        return AnyShapeStyle(Color.white.opacity(0.92))
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        SoftSurface(padding: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(SoftTheme.ink)

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct DetailChip: View {
    enum Style {
        case regular
        case inverted
    }

    let title: String
    let systemImage: String
    var style: Style = .regular

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(foregroundStyle)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(backgroundStyle, in: Capsule())
    }

    private var foregroundStyle: Color {
        switch style {
        case .regular:
            return SoftTheme.ink
        case .inverted:
            return .white
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .regular:
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        SoftTheme.accent.opacity(0.14),
                        SoftTheme.warm.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .inverted:
            AnyShapeStyle(.white.opacity(0.14))
        }
    }
}

private struct SoftSurface<Content: View>: View {
    let padding: CGFloat
    @ViewBuilder let content: Content

    init(
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 16, y: 8)
    }
}

private struct SoftCanvas: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    SoftTheme.accent.opacity(0.08),
                    SoftTheme.warm.opacity(0.08),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(SoftTheme.accent.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 44)
                .offset(x: -120, y: -260)

            Circle()
                .fill(SoftTheme.warm.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 54)
                .offset(x: 150, y: -160)

            Circle()
                .fill(SoftTheme.ink.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 120, y: 320)
        }
        .accessibilityHidden(true)
    }
}

private enum SoftTheme {
    static let accent = Color(red: 0.16, green: 0.63, blue: 0.57)
    static let warm = Color(red: 0.93, green: 0.68, blue: 0.37)
    static let ink = Color(red: 0.14, green: 0.18, blue: 0.28)
}

private enum ExerciseGroupingMode: String, CaseIterable, Identifiable {
    case bodyPart
    case equipment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bodyPart:
            return "Body Part"
        case .equipment:
            return "Equipment"
        }
    }

    var systemImage: String {
        switch self {
        case .bodyPart:
            return "figure.strengthtraining.traditional"
        case .equipment:
            return "hammer.fill"
        }
    }

    func summaryText(for exercises: [CanonicalExercise]) -> String {
        switch self {
        case .bodyPart:
            return "\(Set(exercises.map(\.primaryFocus)).count) body parts"
        case .equipment:
            return "\(Set(exercises.flatMap(\.equipment)).count) equipment types"
        }
    }

    func makeSections(from exercises: [CanonicalExercise]) -> [ExerciseSectionModel] {
        switch self {
        case .bodyPart:
            return bodyPartSections(from: exercises)
        case .equipment:
            return equipmentSections(from: exercises)
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
    let indexLabel: String
    let exercises: [CanonicalExercise]
}

private extension ExerciseSectionModel {
    static func bodyPart(_ bodyPart: CanonicalBodyPart, exercises: [CanonicalExercise]) -> Self {
        Self(
            id: "body-\(bodyPart.id)",
            title: bodyPart.name,
            subtitle: "\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")",
            systemImage: bodyPart.librarySystemImage,
            indexLabel: bodyPart.libraryIndexLabel,
            exercises: exercises
        )
    }

    static func equipment(_ equipment: CanonicalEquipment, exercises: [CanonicalExercise]) -> Self {
        Self(
            id: "equipment-\(equipment.id)",
            title: equipment.name,
            subtitle: "\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")",
            systemImage: equipment.librarySystemImage,
            indexLabel: equipment.libraryIndexLabel,
            exercises: exercises
        )
    }
}

private extension CanonicalBodyPart {
    var librarySystemImage: String {
        switch self {
        case .back:
            return "figure.walk.motion"
        case .biceps:
            return "figure.strengthtraining.functional"
        case .calves:
            return "figure.run"
        case .chest:
            return "heart.text.square.fill"
        case .core:
            return "scope"
        case .forearms:
            return "hand.raised.fill"
        case .glutes:
            return "figure.stand"
        case .hamstrings:
            return "bolt.heart.fill"
        case .quads:
            return "figure.step.training"
        case .shoulders:
            return "figure.arms.open"
        case .triceps:
            return "figure.cooldown"
        }
    }

    var libraryIndexLabel: String {
        switch self {
        case .back:
            return "BAC"
        case .biceps:
            return "BIC"
        case .calves:
            return "CAL"
        case .chest:
            return "CHE"
        case .core:
            return "COR"
        case .forearms:
            return "FOR"
        case .glutes:
            return "GLU"
        case .hamstrings:
            return "HAM"
        case .quads:
            return "QUA"
        case .shoulders:
            return "SHO"
        case .triceps:
            return "TRI"
        }
    }
}

private extension CanonicalEquipment {
    var librarySystemImage: String {
        switch self {
        case .barbell:
            return "dumbbell.fill"
        case .bench, .inclineBench:
            return "bed.double.fill"
        case .bodyweight:
            return "figure.strengthtraining.traditional"
        case .cable, .ropeAttachment:
            return "point.3.connected.trianglepath.dotted"
        case .dipBars, .pullUpBar, .rack:
            return "square.split.2x2"
        case .dumbbell, .kettlebell:
            return "dumbbell"
        case .machine:
            return "gearshape.2.fill"
        }
    }

    var libraryIndexLabel: String {
        switch self {
        case .barbell:
            return "BAR"
        case .bench:
            return "BEN"
        case .bodyweight:
            return "BW"
        case .cable:
            return "CAB"
        case .dipBars:
            return "DIP"
        case .dumbbell:
            return "DB"
        case .inclineBench:
            return "INC"
        case .kettlebell:
            return "KET"
        case .machine:
            return "MAC"
        case .pullUpBar:
            return "PUL"
        case .rack:
            return "RCK"
        case .ropeAttachment:
            return "ROP"
        }
    }
}
