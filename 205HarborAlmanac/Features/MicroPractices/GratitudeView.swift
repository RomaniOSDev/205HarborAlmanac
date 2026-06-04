import SwiftUI

struct GratitudeView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var item1 = ""
    @State private var item2 = ""
    @State private var item3 = ""
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "heart.fill", size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gratitude")
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("1–3 minutes • three appreciations")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .appCard(accent: .accent)

                GratitudeFieldCell(index: 1, text: $item1)
                GratitudeFieldCell(index: 2, text: $item2)
                GratitudeFieldCell(index: 3, text: $item3)

                Button {
                    store.saveGratitude(items: [item1, item2, item3])
                    FeedbackService.success()
                    showSuccess = true
                    item1 = ""; item2 = ""; item3 = ""
                } label: {
                    Label("Save Gratitude", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                if !store.gratitudeEntries.isEmpty {
                    SectionHeaderView(title: "Recent", subtitle: "Your latest lists")
                    ForEach(store.gratitudeEntries.prefix(5)) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            ForEach(entry.items, id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "sparkle")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppAccent"))
                                    Text(item)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                            }
                        }
                        .appCard()
                    }
                }
            }
            .padding(16)
        }
        .successCheckmark(trigger: $showSuccess)
    }
}
