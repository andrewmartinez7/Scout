//
//  SearchResultsView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import UIKit

/// SearchResultsView - Displays search results for athletes and coaches
/// Provides different states: empty search, no results, and results list
struct SearchResultsView: View {
    // MARK: - Environment Objects
    
    /// User view model for search operations
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    /// Search query binding from parent view
    @Binding var query: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            if query.isEmpty {
                emptyStateView
            } else if userViewModel.searchResults.isEmpty {
                noResultsView
            } else {
                resultsListView
            }
        }
    }
    
    // MARK: - View Components
    
    /// Empty state view when no search is performed
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
            
            Text("Search for Athletes and Coaches")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Enter a name or keyword to find users")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    /// No results view when search has no matches
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.slash")
                .font(.system(size: 50))
                .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
            
            Text("No Results Found")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Try a different search term or browse suggested users")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    /// Results list view when search has matches
    private var resultsListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(userViewModel.searchResults) { user in
                    NavigationLink(destination: ProfileOtherView(user: user)) {
                        userRow(user: user)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 76)
                }
            }
        }
    }
    
    /// User row view helper
    private func userRow(user: ScoutModels.User) -> some View {
        HStack(spacing: 16) {
            // Profile image
            ZStack {
                if let profileImage = user.profileImage, let uiImage = UIImage(data: profileImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Text(user.name.prefix(1))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 16, weight: .medium))
                
                if !user.teams.isEmpty {
                    Text(user.teams.joined(separator: ", "))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    @State static var query = "football"
    
    static var previews: some View {
        let viewModel = ScoutUserViewModel()
        viewModel.searchUsers(query: "football")
        
        return SearchResultsView(query: $query)
            .environmentObject(viewModel)
    }
}
