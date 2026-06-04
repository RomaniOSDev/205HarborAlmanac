import SwiftUI

struct BodyScanView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var completed = Set<Int>()
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "figure.mind.and.body", size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Body Scan")
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(completed.count) of \(BodyScanSession.stepTitles.count) steps")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .appCard(accent: .primary)

                ProgressGoalCell(
                    title: "Scan progress",
                    subtitle: "Tap each area when you feel ready",
                    progress: Double(completed.count) / Double(BodyScanSession.stepTitles.count),
                    icon: "list.bullet.clipboard"
                )

                ForEach(Array(BodyScanSession.stepTitles.enumerated()), id: \.offset) { index, title in
                    ChecklistStepCell(
                        index: index,
                        title: title,
                        isCompleted: completed.contains(index)
                    ) {
                        FeedbackService.lightTap()
                        if completed.contains(index) { completed.remove(index) } else { completed.insert(index) }
                    }
                }

                Button {
                    store.saveBodyScan(completedSteps: completed)
                    FeedbackService.success()
                    showSuccess = true
                    completed = []
                } label: {
                    Label("Finish Scan", systemImage: "checkmark.seal.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(completed.isEmpty)
            }
            .padding(16)
        }
        .successCheckmark(trigger: $showSuccess)
    }
}
