//
//  ScoutUserViewModel.swift
//  Scout
//
//  Created by Andrew Martinez on 4/20/25.
//

import SwiftUI
import Combine

/// ScoutUserViewModel - Central data management class for user-related operations
/// Handles authentication, profile data, and user session management
class ScoutUserViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Authentication state
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: ScoutModels.User? = nil
    
    // User data
    @Published var users: [ScoutModels.User] = []
    @Published var conversations: [ScoutModels.Conversation] = []
    @Published var searchResults: [ScoutModels.User] = []
    @Published var recentSearches: [String] = []
    @Published var suggestedUsers: [ScoutModels.User] = []
    
    // MARK: - Initialization
    
    init() {
        // Load mock data for testing
        loadMockData()
    }
    
    // MARK: - Authentication Methods
    
    /// Authenticate user with email and password
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    func login(email: String, password: String) {
        // In a real app, this would validate credentials with a backend service
        // For now, we're simulating a successful login with mock data
        
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
    
    /// Log out the current user
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // MARK: - User Data Methods
    
    /// Search for users matching the query
    /// - Parameter query: Search query string
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // Simple search implementation for mock data
        let lowercasedQuery = query.lowercased()
        searchResults = users.filter { user in
            return user.name.lowercased().contains(lowercasedQuery) ||
                   user.email.lowercased().contains(lowercasedQuery)
        }
        
        // Save to recent searches if not already present
        if !recentSearches.contains(query) && !query.isEmpty {
            recentSearches.insert(query, at: 0)
            // Keep only last 5 searches
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
        }
    }
    
    /// Update the current user's profile
    /// - Parameter updatedUser: Updated user data
    func updateProfile(updatedUser: ScoutModels.User) {
        guard let index = users.firstIndex(where: { $0.id == updatedUser.id }) else { return }
        
        users[index] = updatedUser
        currentUser = updatedUser
    }
    
    // MARK: - Messaging Methods
    
    /// Send a message in a conversation
    /// - Parameters:
    ///   - conversationId: ID of the conversation
    ///   - content: Message content
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
    
    /// Load mock data for testing
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
