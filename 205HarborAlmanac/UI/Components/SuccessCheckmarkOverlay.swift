import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color("AppAccent"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }
}

struct SuccessCheckmarkModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var showCheckmark = false

    func body(content: Content) -> some View {
        ZStack {
            content
            SuccessCheckmarkOverlay(isVisible: $showCheckmark)
        }
        .onChange(of: trigger) { newValue in
            guard newValue else { return }
            FeedbackService.success()
            showCheckmark = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCheckmark = false
                trigger = false
            }
        }
    }
}

extension View {
    func successCheckmark(trigger: Binding<Bool>) -> some View {
        modifier(SuccessCheckmarkModifier(trigger: trigger))
    }
}
