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
                    // Hide the toolbar on this root view to prevent duplicate navigation
                    .toolbar(.hidden, for: .bottomBar)
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
                    // Hide the toolbar on this root view to prevent duplicate navigation
                    .toolbar(.hidden, for: .bottomBar)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(1)
        }
        .accentColor(ScoutColors.primary)
        .onAppear {
            // Set default tab bar appearance
            UITabBar.appearance().backgroundColor = .systemBackground
        }
        .environmentObject(navigationCoordinator)
    }
}
