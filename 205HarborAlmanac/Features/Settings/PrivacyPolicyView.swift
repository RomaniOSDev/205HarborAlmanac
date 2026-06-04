import Foundation
import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    private var policyText: String {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "# Privacy Policy\nContent unavailable."
        }
        return text
    }

    private var policyMarkdown: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        if let parsed = try? AttributedString(markdown: policyText, options: options) {
            return parsed
        }
        return AttributedString(policyText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    Text(policyMarkdown)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
