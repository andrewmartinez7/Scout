//
//  MessagesView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/21/25.
//

import SwiftUI
import Combine

/// MessagesView - Main messaging interface displaying conversation list
/// Provides messaging overview with search and navigation functionality
struct MessagesView: View {
    // MARK: - Environment Properties
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    // MARK: - State Properties
    
    /// Search text for filtering conversations
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    /// Filtered conversations based on search text and sorted by recent activity
    private var filteredConversations: [ScoutModels.Conversation] {
        let conversations = userViewModel.conversations.sorted(by: {
            $0.lastActivityTimestamp > $1.lastActivityTimestamp
        })
        
        guard !searchText.isEmpty else {
            return conversations
        }
        
        return conversations.filter { conversation in
            // Find other participants (not current user)
            let otherParticipants = conversation.participants.filter { participant in
                participant.id != userViewModel.currentUser?.id
            }
            
            // Check if any participant's name matches search
            return otherParticipants.contains { participant in
                participant.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with back navigation
            headerSection
            
            // Search bar for filtering conversations
            searchBarSection
            
            // Main content area
            if filteredConversations.isEmpty {
                emptyStateView
            } else {
                conversationListView
            }
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
    
    /// Header section with back button and title
       private var headerSection: some View {
           ZStack {
               // Background
               Rectangle()
                   .fill(ScoutColors.primaryBlue)
                   .frame(height: 90)
                   .edgesIgnoringSafeArea(.top)
               
               // Header content
               HStack {
                   // Back button
                   Button(action: {
                       presentationMode.wrappedValue.dismiss()
                   }) {
                       Image(systemName: "chevron.left")
                           .font(.system(size: 16, weight: .semibold))
                           .foregroundColor(.white)
                           .padding(8)
                   }
                   .padding(.leading, 8)
                   
                   Spacer()
                   
                   // Title
                   Text("Messages")
                       .font(.system(size: 20, weight: .semibold))
                       .foregroundColor(.white)
                   
                   Spacer()
                   
                   // Balance space
                   Color.clear
                       .frame(width: 32, height: 32)
               }
               .padding(.top, 40) // Safe area accommodation
           }
       }
       
       /// Search bar for filtering conversations
       private var searchBarSection: some View {
           HStack {
               // Search icon
               Image(systemName: "magnifyingglass")
                   .foregroundColor(searchText.isEmpty ? .gray : .primary)
               
               // Search text field
               TextField("Search conversations", text: $searchText)
                   .font(.system(size: 16))
               
               // Clear button
               if !searchText.isEmpty {
                   Button(action: {
                       searchText = ""
                   }) {
                       Image(systemName: "xmark.circle.fill")
                           .foregroundColor(.gray)
                   }
               }
           }
           .padding(10)
           .background(ScoutColors.inputBackground)
           .cornerRadius(10)
           .padding(.horizontal)
           .padding(.vertical, 8)
       }
       
       /// Empty state when no conversations exist
       private var emptyStateView: some View {
           VStack(spacing: 20) {
               Spacer()
               
               // Empty state icon
               Image(systemName: "message.fill")
                   .font(.system(size: 50))
                   .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
               
               // Title
               Text("No Messages Yet")
                   .font(.system(size: 20, weight: .semibold))
               
               // Subtitle
               Text("Start connecting with athletes and coaches")
                   .font(.system(size: 16))
                   .foregroundColor(.gray)
                   .multilineTextAlignment(.center)
               
               // Action button
               NavigationLink(destination: SearchView()) {
                   Text("Find People")
                       .font(.system(size: 16, weight: .medium))
                       .foregroundColor(.white)
                       .padding(.horizontal, 24)
                       .padding(.vertical, 12)
                       .background(ScoutColors.primaryBlue)
                       .cornerRadius(8)
               }
               .padding(.top, 12)
               
               Spacer()
           }
           .padding()
       }
       
       /// List of conversations
       private var conversationListView: some View {
           ScrollView {
               LazyVStack(spacing: 0) {
                   ForEach(filteredConversations) { conversation in
                       NavigationLink(destination: ConversationView(conversation: conversation)) {
                           ConversationRow(
                               conversation: conversation,
                               currentUserId: userViewModel.currentUser?.id
                           )
                       }
                       .buttonStyle(PlainButtonStyle())
                       
                       Divider()
                           .padding(.leading, 76)
                   }
               }
           }
       }
       
       /// Bottom tab bar for navigation
       private var bottomTabBar: some View {
           HStack {
               // Search tab
               Button(action: {
                   navigationCoordinator.resetToSearchRoot()
               }) {
                   VStack {
                       Image(systemName: "magnifyingglass")
                           .font(.system(size: 24))
                       Text("Search")
                           .font(.caption)
                   }
                   .foregroundColor(Color.gray)
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
    }

    // MARK: - Helper Components

    /// Individual conversation row component
    private struct ConversationRow: View {
       let conversation: ScoutModels.Conversation
       let currentUserId: String?
       
       var body: some View {
           HStack(spacing: 12) {
               // Profile image
               ProfileImageView(user: otherUser)
                   .frame(width: 60, height: 60)
               
               // Conversation details
               VStack(alignment: .leading, spacing: 4) {
                   // User name
                   Text(otherUser.name)
                       .font(.system(size: 16, weight: .medium))
                       .foregroundColor(.primary)
                   
                   // Last message preview
                   if let lastMessage = conversation.lastMessage {
                       Text(lastMessage.content)
                           .font(.system(size: 14))
                           .foregroundColor(.gray)
                           .lineLimit(1)
                   }
               }
               
               Spacer()
               
               // Timestamp
               if let lastMessage = conversation.lastMessage {
                   Text(formatTimestamp(lastMessage.timestamp))
                       .font(.system(size: 12))
                       .foregroundColor(.gray)
               }
           }
           .padding()
       }
       
       /// Gets the other user in the conversation (not current user)
       private var otherUser: ScoutModels.User {
           conversation.participants.first { user in
               user.id != currentUserId
           } ?? conversation.participants.first!
       }
       
       /// Formats timestamp for display
       private func formatTimestamp(_ date: Date) -> String {
           let calendar = Calendar.current
           if calendar.isDateInToday(date) {
               let formatter = DateFormatter()
               formatter.timeStyle = .short
               return formatter.string(from: date)
           } else if calendar.isDateInYesterday(date) {
               return "Yesterday"
           } else {
               let formatter = DateFormatter()
               formatter.dateFormat = "MM/dd/yy"
               return formatter.string(from: date)
           }
       }
    }

    /// Reusable profile image component
    private struct ProfileImageView: View {
       let user: ScoutModels.User
       
       var body: some View {
           ZStack {
               if let profileImage = user.profileImage,
                  let uiImage = UIImage(data: profileImage) {
                   Image(uiImage: uiImage)
                       .resizable()
                       .aspectRatio(contentMode: .fill)
                       .frame(width: 60, height: 60)
                       .clipShape(Circle())
               } else {
                   Circle()
                       .fill(Color.gray.opacity(0.3))
                       .overlay(
                           Text(String(user.name.prefix(1)))
                               .font(.system(size: 24, weight: .semibold))
                               .foregroundColor(.gray)
                       )
               }
           }
       }
    }

    // MARK: - Preview

    struct MessagesView_Previews: PreviewProvider {
       static var previews: some View {
           MessagesView()
               .environmentObject(ScoutUserViewModel())
               .environmentObject(NavigationCoordinator())
       }
    }
