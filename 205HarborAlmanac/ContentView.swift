//
//  ContentView.swift
//  205HarborAlmanac
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared
    @EnvironmentObject private var navigation: AppNavigationState

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppNavigationState())
}
