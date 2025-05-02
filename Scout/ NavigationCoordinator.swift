// NavigationCoordinator.swift
import SwiftUI
import Combine

class NavigationCoordinator: ObservableObject {
    @Published var activeTab: Int = 0
    @Published var searchNavigationRoot = UUID()
    @Published var profileNavigationRoot = UUID()
    
    /// Resets to the search root view and activates the search tab
    func resetToSearchRoot() {
        // Only regenerate UUID if we're not already on the tab
        // This prevents unnecessary reloading when already on the tab
        if activeTab != 0 {
            searchNavigationRoot = UUID()
        }
        activeTab = 0
    }
    
    /// Resets to the profile root view and activates the profile tab
    func resetToProfileRoot() {
        // Only regenerate UUID if we're not already on the tab
        // This prevents unnecessary reloading when already on the tab
        if activeTab != 1 {
            profileNavigationRoot = UUID()
        }
        activeTab = 1
    }
}
