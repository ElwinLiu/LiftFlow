import SwiftUI

enum Theme {
    static let accent = Color(red: 0.16, green: 0.63, blue: 0.57)
    static let warm = Color(red: 0.93, green: 0.68, blue: 0.37)
    static let ink = Color(red: 0.14, green: 0.18, blue: 0.28)
}

struct Surface<Content: View>: View {
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

struct BackgroundCanvas: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Theme.accent.opacity(0.08),
                    Theme.warm.opacity(0.08),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Theme.accent.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 44)
                .offset(x: -120, y: -260)

            Circle()
                .fill(Theme.warm.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 54)
                .offset(x: 150, y: -160)

            Circle()
                .fill(Theme.ink.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 120, y: 320)
        }
        .accessibilityHidden(true)
    }
}

struct DetailChip: View {
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
            Theme.ink
        case .inverted:
            .white
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .regular:
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Theme.accent.opacity(0.14),
                        Theme.warm.opacity(0.10)
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

struct ExerciseThumbnailView: View {
    let imageAssetName: String?
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
