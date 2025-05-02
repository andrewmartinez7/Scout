// Scout/Views/Search/SearchView.swift
import SwiftUI
import Combine

struct SearchView: View {
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with messages button
            ZStack {
                Rectangle()
                    .fill(ScoutColors.primaryBlue)
                    .frame(height: 90)
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    Spacer()
                    
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
                .padding(.top, 40) // For safe area
            }
            
            VStack(spacing: 16) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchText.isEmpty ? .gray : .primary)
                    
                    TextField("Search athletes and coaches", text: $searchText)
                        .onChange(of: searchText) { oldValue, newValue in
                            if !newValue.isEmpty {
                                isSearching = true
                                userViewModel.searchUsers(query: newValue)
                            } else {
                                isSearching = false
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            isSearching = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Search results or suggestions
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
                HStack {
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
        }
    }
    
    // Search results view
    private var searchResultsView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if userViewModel.searchResults.isEmpty {
                    // No results
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
                } else {
                    // Results list
                    ForEach(userViewModel.searchResults) { user in
                        NavigationLink(destination: ProfileOtherView(user: user)) {
                            UserListItem(user: user) {
                                // This is now handled by the NavigationLink
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
    }
    
    // Suggestions view
    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recent searches
                if !userViewModel.recentSearches.isEmpty {
                    Text("Recent Searches")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        ForEach(userViewModel.recentSearches, id: \.self) { search in
                            Button(action: {
                                searchText = search
                                isSearching = true
                                userViewModel.searchUsers(query: search)
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
                
                // Suggested users
                if !userViewModel.suggestedUsers.isEmpty {
                    Text("Suggested for You")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        ForEach(userViewModel.suggestedUsers) { user in
                            // This NavigationLink wraps the existing UserListItem to make it clickable
                            NavigationLink(destination: ProfileOtherView(user: user)) {
                                UserListItem(user: user) {
                                    // No action needed here, navigation is handled by the NavigationLink
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
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ScoutUserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
