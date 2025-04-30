//
//  ConversationView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import Combine

struct ConversationView: View {
    @Environment(\.presentationMode) var presentationMode
    // Update to use ScoutUserViewModel
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator

    
    let conversation: ScoutModels.Conversation
    @State private var messageText = ""
    
    // Get the other user (not current user)
    private var otherUser: ScoutModels.User {
        conversation.participants.first { user in
            user.id != userViewModel.currentUser?.id
        } ?? conversation.participants.first!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
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
                
                Spacer()
                
                // User name and photo
                HStack(spacing: 8) {
                    Text(otherUser.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    profileImage(for: otherUser)
                        .frame(width: 32, height: 32)
                }
                
                Spacer()
                
                // Empty view for balance
                Color.clear
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.top, 40) // For safe area
            .background(ScoutColors.primaryBlue)
            
            // Messages
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack(spacing: 12) {
                        ForEach(conversation.messages) { message in
                            messageView(message: message)
                        }
                        .onChange(of: conversation.messages.count) { oldValue, newValue in
                            if let lastMessage = conversation.messages.last {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Message input
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(messageText.isEmpty ? .gray : ScoutColors.primaryBlue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: -1)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
    
    // Message bubble view
    private func messageView(message: ScoutModels.Message) -> some View {
        HStack {
            // Check if current user is sender
            let isCurrentUserSender = message.senderId == userViewModel.currentUser?.id
            
            // Spacer for alignment
            if isCurrentUserSender {
                Spacer()
            }
            
            // Message content
            VStack(alignment: isCurrentUserSender ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUserSender ? ScoutColors.primaryBlue : Color(.systemGray6))
                    .foregroundColor(isCurrentUserSender ? .white : .primary)
                    .cornerRadius(16)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isCurrentUserSender ? .trailing : .leading)
            
            // Spacer for alignment
            if !isCurrentUserSender {
                Spacer()
            }
        }
        .id(message.id) // For ScrollViewReader
    }
    
    // Profile image view
    private func profileImage(for user: ScoutModels.User) -> some View {
        ZStack {
            if let profileImage = user.profileImage, let uiImage = UIImage(data: profileImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.white)
                
                Text(String(user.name.prefix(1)))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ScoutColors.primaryBlue)
            }
        }
    }
    
    // Format timestamp for display
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Send a new message
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        userViewModel.sendMessage(conversationId: conversation.id, content: messageText)
        messageText = ""
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock conversation for preview
        let viewModel = ScoutUserViewModel()
        
        return ConversationView(conversation: viewModel.conversations.first!)
            .environmentObject(viewModel)
    }
}
