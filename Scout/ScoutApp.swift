//
//  ScoutApp.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

@main
struct ScoutApp: App {
    // Use ScoutUserViewModel consistently
    @StateObject private var userViewModel = ScoutUserViewModel()
    
    var body: some Scene {
        WindowGroup {
            // Conditionally display the main app or login screen based on authentication state
            if userViewModel.isAuthenticated {
                ScoutMainTabView()
                    .environmentObject(userViewModel)
            } else {
                ImprovedLoginView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
