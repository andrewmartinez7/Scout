//
//  UserViewModel.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    // Authentication state
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: ScoutModels.User? = nil
    
    // User data
    @Published var users: [ScoutModels.User] = []
    @Published var conversations: [ScoutModels.Conversation] = []
    @Published var searchResults: [ScoutModels.User] = []
    @Published var recentSearches: [String] = []
    @Published var suggestedUsers: [ScoutModels.User] = []
    
    init() {
        loadMockData()
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) {
        if let user = users.first(where: { $0.email == email }) {
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            // Create a new user if not found (for testing only)
            let newUser = ScoutModels.User(
                id: UUID().uuidString,
                name: "New User",
                email: email,
                profileImage: nil,
                backgroundImage: nil,
                backgroundInfo: "",
                teams: [],
                videos: []
            )
            
            self.users.append(newUser)
            self.currentUser = newUser
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // MARK: - User Data Methods
    
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let lowercasedQuery = query.lowercased()
        searchResults = users.filter { user in
            return user.name.lowercased().contains(lowercasedQuery) ||
                   user.email.lowercased().contains(lowercasedQuery)
        }
        
        if !recentSearches.contains(query) && !query.isEmpty {
            recentSearches.insert(query, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
        }
    }
    
    func updateProfile(updatedUser: ScoutModels.User) {
        guard let index = users.firstIndex(where: { $0.id == updatedUser.id }) else { return }
        
        users[index] = updatedUser
        currentUser = updatedUser
    }
    
    // MARK: - Messaging Methods
    
    func sendMessage(conversationId: String, content: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }),
              let currentUser = currentUser else { return }
        
        let newMessage = ScoutModels.Message(
            id: UUID().uuidString,
            senderId: currentUser.id,
            content: content,
            timestamp: Date()
        )
        
        conversations[index].messages.append(newMessage)
    }
    
    // MARK: - Private Methods
    
    private func loadMockData() {
        // Create mock users
        let user1 = ScoutModels.User(
            id: "1",
            name: "John Smith",
            email: "john@example.com",
            profileImage: nil,
            backgroundImage: nil,
            backgroundInfo: "High school quarterback with strong passing skills. Looking to play college football.",
            teams: ["High School Football Team"],
            videos: [
                ScoutModels.Video(id: "1", title: "Football Highlights", thumbnailImage: nil, url: nil, uploadDate: Date())
            ]
        )
        
        let user2 = ScoutModels.User(
            id: "2",
            name: "Coach Johnson",
            email: "coach@example.com",
            profileImage: nil,
            backgroundImage: nil,
            backgroundInfo: "College football coach with 15 years of experience. Looking for talented quarterbacks.",
            teams: ["University Football Team"],
            videos: []
        )
        
        users = [user1, user2]
        
        // Create mock conversations
        let conversation = ScoutModels.Conversation(
            id: "1",
            participants: [user1, user2],
            messages: [
                ScoutModels.Message(id: "1", senderId: "1", content: "Hello Coach, I'm interested in your program", timestamp: Date().addingTimeInterval(-86400)),
                ScoutModels.Message(id: "2", senderId: "2", content: "Hi John, thanks for reaching out. I'd love to see your highlights.", timestamp: Date().addingTimeInterval(-43200))
            ]
        )
        
        conversations = [conversation]
        
        // Set suggested users
        suggestedUsers = [user2]
    }
}
