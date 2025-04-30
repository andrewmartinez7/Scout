//
//  ScoutModels.swift
//  Scout
//
//  Created by Andrew Martinez on 4/20/25.
//

import SwiftUI

/// ScoutModels - Namespace for all model structs used in the Scout app
/// This avoids naming conflicts with existing models in the project
enum ScoutModels {
    /// User - Model representing a user in the Scout app
    struct User: Identifiable, Codable, Equatable {
        // MARK: - Properties
        
        // Core properties
        var id: String
        var name: String
        var email: String
        
        // Profile media
        var profileImage: Data?
        var backgroundImage: Data?
        
        // Background information
        var backgroundInfo: String = ""
        
        // Additional information
        var teams: [String]
        var videos: [Video]
        
        // MARK: - Initialization
        
        init(id: String, name: String, email: String, profileImage: Data?, backgroundImage: Data?, backgroundInfo: String = "", teams: [String], videos: [Video]) {
            self.id = id
            self.name = name
            self.email = email
            self.profileImage = profileImage
            self.backgroundImage = backgroundImage
            self.backgroundInfo = backgroundInfo
            self.teams = teams
            self.videos = videos
        }
        
        // MARK: - Equatable
        
        static func == (lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    /// Video - Model representing a highlight video in the Scout app
    struct Video: Identifiable, Codable, Equatable {
        // MARK: - Properties
        
        // Core properties
        var id: String
        var title: String
        var thumbnailImage: Data?
        var url: URL?
        var uploadDate: Date
        
        // MARK: - Equatable
        
        static func == (lhs: Video, rhs: Video) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    /// Message - Model representing a single message in a conversation
    struct Message: Identifiable, Codable, Equatable {
        // MARK: - Properties
        
        var id: String
        var senderId: String
        var content: String
        var timestamp: Date
        
        // MARK: - Equatable
        
        static func == (lhs: Message, rhs: Message) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    /// Conversation - Model representing a messaging thread between users
    struct Conversation: Identifiable, Codable, Equatable {
        // MARK: - Properties
        
        var id: String
        var participants: [User]
        var messages: [Message]
        
        // MARK: - Computed Properties
        
        /// Returns the most recent message in the conversation
        var lastMessage: Message? {
            return messages.sorted(by: { $0.timestamp > $1.timestamp }).first
        }
        
        /// Returns the last activity timestamp
        var lastActivityTimestamp: Date {
            return lastMessage?.timestamp ?? Date(timeIntervalSince1970: 0)
        }
        
        // MARK: - Equatable
        
        static func == (lhs: Conversation, rhs: Conversation) -> Bool {
            return lhs.id == rhs.id
        }
    }
}
