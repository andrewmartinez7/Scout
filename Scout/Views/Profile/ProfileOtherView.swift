//
//  ProfileOtherView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import UIKit

struct ProfileOtherView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    let user: ScoutModels.User
    
    var body: some View {
        VStack(spacing: 0) {
            ScoutHeader(
                title: "Profile",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // Profile header section
                    profileHeaderSection
                    
                    // Background information section
                    backgroundSection
                    
                    // Teams section
                    teamsSection
                    
                    // Videos section
                    videosSection
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
    
    // Profile header with image and name
    private var profileHeaderSection: some View {
        ZStack(alignment: .top) {
            // Background image
            if let backgroundImage = user.backgroundImage, let uiImage = UIImage(data: backgroundImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
            }
            
            VStack {
                Spacer()
                    .frame(height: 70)
                
                // Profile image
                if let profileImage = user.profileImage, let uiImage = UIImage(data: profileImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    
                    Text(user.name.prefix(1))
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(ScoutColors.primaryBlue)
                }
                
                // Name
                Text(user.name)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 12)
                
                // Message button
                Button(action: {
                    // Message action
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14))
                        
                        Text("Message")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(ScoutColors.primaryBlue)
                    .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // Background information section
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.system(size: 18, weight: .semibold))
            
            if !user.backgroundInfo.isEmpty {
                Text(user.backgroundInfo)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("No background information provided.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    // Teams section
    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Teams")
                .font(.system(size: 18, weight: .semibold))
            
            if !user.teams.isEmpty {
                ForEach(user.teams, id: \.self) { team in
                    HStack {
                        Text(team)
                            .font(.system(size: 15))
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No teams listed.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    // Videos section
    private var videosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlight Videos")
                .font(.system(size: 18, weight: .semibold))
            
            if !user.videos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(user.videos) { video in
                            NavigationLink(destination: VideoPlayerView(video: video)) {
                                VideoThumbnail(
                                    title: video.title,
                                    thumbnailImage: video.thumbnailImage != nil ? UIImage(data: video.thumbnailImage!) : nil,
                                    onTap: {}
                                )
                                .frame(width: 180)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No highlight videos available.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct ProfileOtherView_Previews: PreviewProvider {
    static var previews: some View {
        let mockUser = ScoutModels.User(
            id: "1",
            name: "John J Smith",
            email: "john@example.com",
            profileImage: nil,
            backgroundImage: nil,
            backgroundInfo: "High school quarterback with strong passing skills. Looking to play college football.",
            teams: ["High School Football Team"],
            videos: [
                ScoutModels.Video(id: "1", title: "Football Highlights", thumbnailImage: nil, url: nil, uploadDate: Date())
            ]
        )
        
        return ProfileOtherView(user: mockUser)
            .environmentObject(ScoutUserViewModel())
    }
}
