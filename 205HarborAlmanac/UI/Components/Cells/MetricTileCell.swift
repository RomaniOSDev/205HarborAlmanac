import SwiftUI

struct MetricTileCell: View {
    let icon: String
    let title: String
    let value: String
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            HStack(spacing: 8) {
                IconBadge(systemName: icon, size: compact ? 36 : 40, filled: true)
                Text(title)
                    .font(compact ? .caption : .subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Text(value)
                .font(compact ? .title3.bold() : .title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(accent: .accent, padding: compact ? 12 : 14)
    }
}

struct MetricsGridRow: View {
    let tiles: [(icon: String, title: String, value: String)]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(tiles.enumerated()), id: \.offset) { _, tile in
                MetricTileCell(icon: tile.icon, title: tile.title, value: tile.value, compact: true)
            }
        }
    }
}

struct ProgressGoalCell: View {
    let title: String
    let subtitle: String
    let progress: Double
    var icon: String = "target"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("AppBackground"))
                    Capsule()
                        .fill(AppGradients.progressFill)
                        .frame(width: max(12, geo.size.width * progress))
                }
            }
            .frame(height: 12)
            Text("\(Int(progress * 100))% complete")
                .font(.caption.bold())
                .foregroundStyle(Color("AppAccent"))
        }
        .appCard(accent: .primary)
    }
}
