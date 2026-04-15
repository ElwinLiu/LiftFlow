import SwiftUI

struct HomeView: View {
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
            BackgroundCanvas()

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
        Surface {
            VStack(alignment: .leading, spacing: 14) {
                Label("What’s Ready", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)

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
                            Theme.ink,
                            Theme.accent,
                            Theme.warm
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
                .fill(Theme.warm.opacity(0.28))
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
        .shadow(color: Theme.ink.opacity(0.18), radius: 18, y: 10)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        Surface(padding: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
