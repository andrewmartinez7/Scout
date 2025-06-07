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
    
    /// Focus state for search field
    @FocusState private var isSearchFieldFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with messages navigation
            headerSection
            
            // Main content area
            VStack(spacing: 0) {
                // Search input bar
                searchBarSection
                
                // Dynamic content based on search state
                contentSection
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onTapGesture {
            // Only dismiss keyboard when tapping outside search area
            if isSearchFieldFocused {
                isSearchFieldFocused = false
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
        HStack(spacing: 8) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            // Search text field
            TextField("Search athletes and coaches", text: $searchText)
                .focused($isSearchFieldFocused)
                .font(.system(size: 16))
                .textFieldStyle(PlainTextFieldStyle())
                .submitLabel(.search)
                .onChange(of: searchText) { oldValue, newValue in
                    handleSearchTextChange(newValue)
                }
                .onSubmit {
                    // Handle search submission
                    if !searchText.isEmpty {
                        performSearch(searchText)
                    }
                }
                .onTapGesture {
                    // Ensure focus when tapped
                    isSearchFieldFocused = true
                }
            
            // Clear button (shown when text exists)
            if !searchText.isEmpty {
                Button(action: clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onTapGesture {
            // Focus when tapping anywhere in the search bar area
            isSearchFieldFocused = true
        }
    }
    
    /// Main content section that changes based on search state
    private var contentSection: some View {
        Group {
            if isSearchFieldFocused && searchText.isEmpty {
                // Show recent searches when focused but no text entered
                recentSearchesOnlyView
            } else if isSearching {
                searchResultsView
            } else {
                suggestionsView
            }
        }
    }
    
    /// Search results display when actively searching
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
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
            Spacer()
            
            Image(systemName: "person.slash")
                .font(.system(size: 50))
                .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
                .padding(.top, 60)
            
            Text("No results found for \"\(searchText)\"")
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
            
            Text("Try a different search term or browse suggested users below")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    /// List of search results
    private var searchResultsList: some View {
        ForEach(userViewModel.searchResults) { user in
            NavigationLink(destination: ProfileOtherView(user: user)) {
                SearchResultRow(user: user)
            }
            .buttonStyle(PlainButtonStyle())
            
            if user.id != userViewModel.searchResults.last?.id {
                Divider()
                    .padding(.leading, 76)
            }
        }
    }
    
    /// Suggestions view when not actively searching
    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Suggested users section (no recent searches here)
                if !userViewModel.suggestedUsers.isEmpty {
                    suggestedUsersSection
                } else {
                    // Show empty state with instructions
                    emptyStateInstructions
                }
                
                Spacer(minLength: 100) // Bottom padding for tab bar
            }
            .padding(.top, 8)
        }
    }
    
    /// Empty state instructions when no suggestions available
    private var emptyStateInstructions: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
                .padding(.top, 40)
            
            Text("Discover Athletes and Coaches")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Use the search bar above to find athletes and coaches by name, team, or sport")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Recent searches view when search field is focused but empty
    private var recentSearchesOnlyView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !userViewModel.recentSearches.isEmpty {
                    recentSearchesSection
                } else {
                    // Show helpful text when no recent searches
                    VStack(spacing: 12) {
                        Text("No recent searches")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                        
                        Text("Start typing to search for athletes and coaches")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.top, 8)
        }
    }
    
    /// Recent searches history section
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recent Searches")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Clear") {
                    userViewModel.recentSearches.removeAll()
                }
                .font(.system(size: 14))
                .foregroundColor(ScoutColors.primaryBlue)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                ForEach(userViewModel.recentSearches, id: \.self) { search in
                    Button(action: {
                        performSearch(search)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            Text(search)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.left")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if search != userViewModel.recentSearches.last {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            .padding(.horizontal, 16)
        }
    }
    
    /// Suggested users section
    private var suggestedUsersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Suggested for You")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                ForEach(userViewModel.suggestedUsers) { user in
                    NavigationLink(destination: ProfileOtherView(user: user)) {
                        SuggestedUserRow(user: user)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if user.id != userViewModel.suggestedUsers.last?.id {
                        Divider()
                            .padding(.leading, 76)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Actions
    
    /// Handles search text changes with real-time search
    /// - Parameter newValue: The new search text
    private func handleSearchTextChange(_ newValue: String) {
        // Debounce search to avoid too many calls
        if !newValue.isEmpty {
            isSearching = true
            // Perform search with slight delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.searchText == newValue { // Make sure text hasn't changed
                    self.userViewModel.searchUsers(query: newValue)
                }
            }
        } else {
            isSearching = false
            userViewModel.searchResults = []
        }
    }
    
    /// Clears the current search
    private func clearSearch() {
        searchText = ""
        isSearching = false
        userViewModel.searchResults = []
        isSearchFieldFocused = false
    }
    
    /// Performs a search with the given query
    /// - Parameter query: The search query to execute
    private func performSearch(_ query: String) {
        searchText = query
        isSearching = true
        isSearchFieldFocused = false
        userViewModel.searchUsers(query: query)
    }
}

// MARK: - Helper Components

/// Search result row component
private struct SearchResultRow: View {
    let user: ScoutModels.User
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            UserAvatarView(user: user, size: 60)
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if !user.teams.isEmpty {
                    Text(user.teams.joined(separator: ", "))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("No teams listed")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                if !user.backgroundInfo.isEmpty {
                    Text(user.backgroundInfo)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

/// Suggested user row component
private struct SuggestedUserRow: View {
    let user: ScoutModels.User
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            UserAvatarView(user: user, size: 60)
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Suggested")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ScoutColors.primaryBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ScoutColors.primaryBlue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if !user.teams.isEmpty {
                    Text(user.teams.joined(separator: ", "))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !user.backgroundInfo.isEmpty {
                    Text(user.backgroundInfo)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ScoutUserViewModel()
        
        return SearchView()
            .environmentObject(viewModel)
            .environmentObject(NavigationCoordinator())
    }
}
