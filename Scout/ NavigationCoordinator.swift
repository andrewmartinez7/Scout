// NavigationCoordinator.swift
import SwiftUI
import Combine

class NavigationCoordinator: ObservableObject {
    @Published var activeTab: Int = 0
    @Published var searchNavigationRoot = UUID()
    @Published var profileNavigationRoot = UUID()
    
    /// Resets to the search root view and activates the search tab
    /// Always resets the navigation stack, even if already on search tab
    func resetToSearchRoot() {
        // Always regenerate UUID to reset navigation stack
        searchNavigationRoot = UUID()
        activeTab = 0
    }
    
    /// Resets to the profile root view and activates the profile tab
    /// Always resets the navigation stack, even if already on profile tab
    func resetToProfileRoot() {
        // Always regenerate UUID to reset navigation stack
        profileNavigationRoot = UUID()
        activeTab = 1
    }
}
