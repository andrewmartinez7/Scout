// ScoutMainTabView.swift
import SwiftUI

/// ScoutMainTabView - Main navigation container for the authenticated Scout app experience
/// Provides tab-based navigation between the major app sections
struct ScoutMainTabView: View {
    // MARK: - Properties
    
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @State private var lastTappedTab: Int = 0
    @State private var lastTapTime: Date = Date()
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $navigationCoordinator.activeTab) {
            // Search tab
            NavigationView {
                SearchView()
                    .id(navigationCoordinator.searchNavigationRoot)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(0)
            
            // Profile tab
            NavigationView {
                ProfileSelfView()
                    .id(navigationCoordinator.profileNavigationRoot)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(1)
        }
        .accentColor(ScoutColors.primaryBlue)
        .onAppear {
            // Set default tab bar appearance
            UITabBar.appearance().backgroundColor = .systemBackground
        }
        .environmentObject(navigationCoordinator)
        // Handle tab selection changes
        .onChange(of: navigationCoordinator.activeTab) { oldValue, newValue in
            let now = Date()
            
            // If same tab is selected within a short time frame, it's likely a re-tap
            if oldValue == newValue && now.timeIntervalSince(lastTapTime) < 0.5 {
                // Reset navigation for the active tab
                if newValue == 0 {
                    navigationCoordinator.resetToSearchRoot()
                } else if newValue == 1 {
                    navigationCoordinator.resetToProfileRoot()
                }
            }
            
            lastTappedTab = newValue
            lastTapTime = now
        }
    }
}
