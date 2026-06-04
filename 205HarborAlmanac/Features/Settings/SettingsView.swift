import StoreKit
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showShareJSON = false
    @State private var showShareCSV = false
    @State private var showImporter = false
    @State private var exportJSONData: Data?
    @State private var exportCSVString = ""
    @State private var importError: String?

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        statsSection
                        remindersSection
                        backupSection
                        legalSection
                        versionFooter
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showShareJSON) {
                if let exportJSONData { ShareSheet(items: [exportJSONData]) }
            }
            .sheet(isPresented: $showShareCSV) { ShareSheet(items: [exportCSVString]) }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { importBackup($0) }
            .alert("Import Failed", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(importError ?? "") }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { resetData() }
            } message: { Text("This will permanently delete all data on this device.") }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Stats", subtitle: "Your activity on this device")
            MetricsGridRow(tiles: [
                ("book.fill", "Entries", "\(store.entriesCreated)"),
                ("clock.fill", "Minutes", "\(store.totalMinutesUsed)")
            ])
            MetricTileCell(icon: "flame.fill", title: "Current streak", value: "\(store.streakDays) days", compact: false)
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Reminders", subtitle: "Local notifications only")
            VStack(spacing: 10) {
                reminderToggleRow(title: "Morning check-in", icon: "sun.max.fill", isOn: binding(\.morningEnabled))
                if store.reminderSettings.morningEnabled {
                    DatePicker("Morning time", selection: morningDateBinding, displayedComponents: .hourAndMinute)
                        .tint(Color("AppPrimary"))
                }
                reminderToggleRow(title: "Evening wind-down", icon: "moon.stars.fill", isOn: binding(\.eveningEnabled))
                if store.reminderSettings.eveningEnabled {
                    DatePicker("Evening time", selection: eveningDateBinding, displayedComponents: .hourAndMinute)
                        .tint(Color("AppPrimary"))
                }
                Button {
                    NotificationScheduler.requestAuthorization { granted in
                        if granted {
                            store.updateReminderSettings(store.reminderSettings)
                            FeedbackService.success()
                        } else { FeedbackService.warning() }
                    }
                } label: {
                    Label("Enable Notifications", systemImage: "bell.badge.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .appCard(accent: .accent)
        }
    }

    private func reminderToggleRow(title: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, size: 40)
            Toggle(title, isOn: isOn)
                .tint(Color("AppPrimary"))
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Backup", subtitle: "Export or restore your data")
            ActionRowButton(icon: "square.and.arrow.up", title: "Export JSON", subtitle: "Full backup for import later") { exportJSON() }
            ActionRowButton(icon: "tablecells", title: "Export CSV", subtitle: "Journal entries spreadsheet") { exportCSV() }
            ActionRowButton(icon: "square.and.arrow.down", title: "Import JSON Backup", subtitle: "Restore after reset") {
                showImporter = true
            }
        }
    }

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Legal")
            ActionRowButton(icon: "star.fill", title: "Rate Us", subtitle: "Share your experience on the App Store") {
                rateApp()
            }
            ActionRowButton(icon: "hand.raised.fill", title: "Privacy Policy", subtitle: "How your data is handled") {
                openPrivacyPolicy()
            }
            ActionRowButton(icon: "doc.text.fill", title: "Terms of Use", subtitle: "Usage terms and conditions") {
                openTermsOfUse()
            }
            ActionRowButton(icon: "trash.fill", title: "Reset All Data", subtitle: "Cannot be undone", destructive: true) {
                showResetAlert = true
            }
        }
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private func binding(_ keyPath: WritableKeyPath<ReminderSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { store.reminderSettings[keyPath: keyPath] },
            set: { newValue in
                var settings = store.reminderSettings
                settings[keyPath: keyPath] = newValue
                store.updateReminderSettings(settings)
            }
        )
    }

    private var morningDateBinding: Binding<Date> {
        dateBinding(hour: \.morningHour, minute: \.morningMinute)
    }

    private var eveningDateBinding: Binding<Date> {
        dateBinding(hour: \.eveningHour, minute: \.eveningMinute)
    }

    private func dateBinding(hour: WritableKeyPath<ReminderSettings, Int>, minute: WritableKeyPath<ReminderSettings, Int>) -> Binding<Date> {
        Binding(
            get: {
                var c = DateComponents()
                c.hour = store.reminderSettings[keyPath: hour]
                c.minute = store.reminderSettings[keyPath: minute]
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                var settings = store.reminderSettings
                settings[keyPath: hour] = parts.hour ?? 9
                settings[keyPath: minute] = parts.minute ?? 0
                store.updateReminderSettings(settings)
            }
        )
    }

    private func exportJSON() {
        FeedbackService.lightTap()
        do {
            exportJSONData = try DataTransferService.makeJSONExport(from: store)
            showShareJSON = true
        } catch { importError = "Could not create JSON export." }
    }

    private func exportCSV() {
        FeedbackService.lightTap()
        exportCSVString = DataTransferService.makeCSVExport(from: store)
        showShareCSV = true
    }

    private func importBackup(_ result: Result<[URL], Error>) {
        switch result {
        case .failure: importError = "File selection cancelled."
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                try DataTransferService.importJSON(try Data(contentsOf: url), into: store)
                FeedbackService.success()
            } catch { importError = "Invalid backup file." }
        }
    }

    private func rateApp() {
        FeedbackService.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openPrivacyPolicy() {
        FeedbackService.lightTap()
        if let url = AppExternalLinks.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        FeedbackService.lightTap()
        if let url = AppExternalLinks.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    private func resetData() {
        FeedbackService.warning()
        store.resetAllData()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }
}
