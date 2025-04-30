// MessagesView.swift
import SwiftUI
import Combine

struct MessagesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var searchText = ""
    
    // Filtered conversations based on search text
    private var filteredConversations: [ScoutModels.Conversation] {
        guard !searchText.isEmpty else {
            return userViewModel.conversations.sorted(by: { $0.lastActivityTimestamp > $1.lastActivityTimestamp })
        }
        
        return userViewModel.conversations.filter { conversation in
            // Find other participant(s) in the conversation
            let otherParticipants = conversation.participants.filter { participant in
                participant.id != userViewModel.currentUser?.id
            }
            
            // Check if any participant's name matches the search
            return otherParticipants.contains { participant in
                participant.name.lowercased().contains(searchText.lowercased())
            }
        }
        .sorted(by: { $0.lastActivityTimestamp > $1.lastActivityTimestamp })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            ZStack {
                Rectangle()
                    .fill(ScoutColors.primaryBlue)
                    .frame(height: 90)
                    .edgesIgnoringSafeArea(.top)
                
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
                    
                    Text("Messages")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                .padding(.top, 40) // For safe area
            }
            
            // Search bar for conversations
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(searchText.isEmpty ? .gray : .primary)
                
                TextField("Search conversations", text: $searchText)
                    .font(.system(size: 16))
                
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
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if filteredConversations.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 50))
                        .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
                    
                    Text("No Messages Yet")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Start connecting with athletes and coaches")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
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
            } else {
                // Conversation list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredConversations) { conversation in
                            NavigationLink(destination: ConversationView(conversation: conversation)) {
                                conversationRow(conversation: conversation)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
            }
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
                        .foregroundColor(Color.gray)
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
    
    // Single conversation row
    private func conversationRow(conversation: ScoutModels.Conversation) -> some View {
        HStack(spacing: 12) {
            // Get the other user (not current user)
            let otherUser = conversation.participants.first { user in
                user.id != userViewModel.currentUser?.id
            } ?? conversation.participants.first!
            
            // Profile image
            profileImage(for: otherUser)
                .frame(width: 60, height: 60)
            
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
    
    // Profile image view
    private func profileImage(for user: ScoutModels.User) -> some View {
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
                
                Text(String(user.name.prefix(1)))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Format timestamp for display
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

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            .environmentObject(ScoutUserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
