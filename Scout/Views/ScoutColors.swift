//
//  ScoutColors.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

/// ScoutColors - Centralized color definitions for the Scout app
/// Contains all app color definitions to maintain consistency across the UI
struct ScoutColors {
    // Primary brand colors
    static let primary = Color(red: 0.25, green: 0.55, blue: 0.9)
    static let primaryDark = Color(red: 0.2, green: 0.4, blue: 0.8)
    
    // Named color aliases (to fix the errors)
    static let primaryBlue = Color(red: 0.25, green: 0.55, blue: 0.9)
    static let textGray = Color.gray
    
    // Secondary UI colors
    static let background = Color.white
    static let inputBackground = Color(UIColor.systemGray6)
    
    // Text colors
    static let primaryText = Color.black
    static let secondaryText = Color.gray
    
    // Social login colors
    static let facebookBlue = Color(red: 0.23, green: 0.35, blue: 0.6)
    static let appleBlack = Color.black
}

