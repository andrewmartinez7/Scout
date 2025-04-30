//
//   NavigationCoordinator.swift
//  Scout
//
//  Created by Andrew Martinez on 4/22/25.
//

// NavigationCoordinator.swift
import SwiftUI
import Combine

class NavigationCoordinator: ObservableObject {
    @Published var activeTab: Int = 0
    @Published var searchNavigationRoot = UUID()
    @Published var profileNavigationRoot = UUID()
    
    func resetToSearchRoot() {
        activeTab = 0
        searchNavigationRoot = UUID()
    }
    
    func resetToProfileRoot() {
        activeTab = 1
        profileNavigationRoot = UUID()
    }
}
