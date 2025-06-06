//
//  SearchView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import Combine

/// SearchView - Main search interface for finding athletes and coaches
/// Provides search functionality with real-time results and suggestions
struct SearchView: View {
    // MARK: - Environment Objects
    
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    // MARK: - State Properties
    
    /// Current search text input
    @State private var searchText = ""
    
    /// Whether user is actively searching
    @State private var isSearching = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with messages navigation
            headerSection
            
            // Main content area
            VStack(spacing: 16) {
                // Search input bar
                searchBarSection
                
                // Dynamic content based on search state
                if isSearching {
                    searchResultsView
                } else {
                    suggestionsView
                }
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                bottomTabBar
            }
        }
    }
    
    // MARK: - View Components
    
    /// Header section with title and messages button
    private var headerSection: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(ScoutColors.primaryBlue)
                .frame(height: 90)
                .edgesIgnoringSafeArea(.top)
            
            // Header content
            HStack {
                Spacer()
                
                // Title
                Text("Search")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Messages button
                NavigationLink(destination: MessagesView()) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(8)
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 40) // Safe area accommodation
        }
    }
    
    /// Search input bar with real-time search functionality
    private var searchBarSection: some View {
        HStack {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(searchText.isEmpty ? .gray : .primary)
            
            // Search text field
            TextField("Search athletes and coaches", text: $searchText)
                .onChange(of: searchText) { oldValue, newValue in
                    handleSearchTextChange(newValue)
                }
            
            // Clear button (shown when text exists)
            if !searchText.isEmpty {
                Button(action: clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(ScoutColors.inputBackground)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    /// Bottom tab bar for navigation
    private var bottomTabBar: some View {
        HStack {
            // Search tab (active)
            Button(action: {
                navigationCoordinator.resetToSearchRoot()
            }) {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                    Text("Search")
                        .font(.caption)
                }
                .foregroundColor(Color.blue)
            }
            
            Spacer()
            
            // Profile tab
            Button(action: {
                navigationCoordinator.resetToProfileRoot()
            }) {
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                    Text("Profile")
                        .font(.caption)
                }
                .foregroundColor(Color.gray)
            }
        }
        .padding(.horizontal, 40)
    }
    
    /// Search results display when actively searching
    private var searchResultsView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if userViewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
        }
    }
    
    /// Empty state when no search results found
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Text("No results found")
                .font(.system(size: 18, weight: .medium))
                .padding(.top, 40)
            
            Text("Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    /// List of search results
    private var searchResultsList: some View {
        ForEach(userViewModel.searchResults) { user in
            NavigationLink(destination: ProfileOtherView(user: user)) {
                UserListItem(user: user) {
                    // Navigation handled by NavigationLink
                }
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .padding(.leading)
        }
    }
    
    /// Suggestions view when not actively searching
    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recent searches section
                if !userViewModel.recentSearches.isEmpty {
                    recentSearchesSection
                }
                
                // Suggested users section
                if !userViewModel.suggestedUsers.isEmpty {
                    suggestedUsersSection
                }
            }
        }
    }
    
    /// Recent searches history section
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Searches")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal)
                .padding(.top, 8)
            
            VStack(spacing: 0) {
                ForEach(userViewModel.recentSearches, id: \.self) { search in
                    Button(action: {
                        performSearch(search)
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            
                            Text(search)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
    
    /// Suggested users section
    private var suggestedUsersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Suggested for You")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal)
                .padding(.top, 8)
            
            VStack(spacing: 0) {
                ForEach(userViewModel.suggestedUsers) { user in
                    NavigationLink(destination: ProfileOtherView(user: user)) {
                        UserListItem(user: user) {
                            // Navigation handled by NavigationLink
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    /// Handles search text changes with real-time search
    /// - Parameter newValue: The new search text
    private func handleSearchTextChange(_ newValue: String) {
        if !newValue.isEmpty {
            isSearching = true
            userViewModel.searchUsers(query: newValue)
        } else {
            isSearching = false
        }
    }
    
    /// Clears the current search
    private func clearSearch() {
        searchText = ""
        isSearching = false
    }
    
    /// Performs a search with the given query
    /// - Parameter query: The search query to execute
    private func performSearch(_ query: String) {
        searchText = query
        isSearching = true
        userViewModel.searchUsers(query: query)
    }
}

// MARK: - Preview

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ScoutUserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
