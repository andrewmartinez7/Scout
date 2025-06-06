// ScoutMainTabView.swift
import SwiftUI

/// ScoutMainTabView - Main navigation container for the authenticated Scout app experience
/// Provides tab-based navigation between the major app sections
struct ScoutMainTabView: View {
    // MARK: - Properties
    
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
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
        // Listen for navigation coordinator changes
        .onChange(of: navigationCoordinator.searchNavigationRoot) { _, _ in
            // Navigation root changed, ensure we're on the right tab
            if navigationCoordinator.activeTab == 0 {
                // Force update by changing selection
                DispatchQueue.main.async {
                    navigationCoordinator.activeTab = 0
                }
            }
        }
        .onChange(of: navigationCoordinator.profileNavigationRoot) { _, _ in
            // Navigation root changed, ensure we're on the right tab
            if navigationCoordinator.activeTab == 1 {
                // Force update by changing selection
                DispatchQueue.main.async {
                    navigationCoordinator.activeTab = 1
                }
            }
        }
    }
}
