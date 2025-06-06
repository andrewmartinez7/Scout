//
//  ProfileSelfView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.


// ProfileSelfView.swift
import SwiftUI
import UIKit

/// ProfileSelfView - User's own profile view showing their information, teams, and videos
struct ProfileSelfView: View {
    // MARK: - Properties
    
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @State private var showAddVideoSheet = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with settings button - Keep this outside the ScrollView
            ZStack {
                Rectangle()
                    .fill(ScoutColors.primaryBlue)
                    .frame(height: 90)
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    // "Scout" text with thicker, more professional font
                    Text("Scout")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Settings button
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 40) // For safe area
            }
            
            // Use ScrollView for the content - Make it fill the available space
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) { // Remove spacing between elements to fix gap
                    // Profile header section
                    profileHeaderSection
                    
                    // Content sections with spacing
                    VStack(spacing: 16) {
                        // Background information section
                        if let user = userViewModel.currentUser {
                            backgroundSection(user: user)
                        }
                        
                        // Teams section
                        if let user = userViewModel.currentUser {
                            teamsSection(user: user)
                        }
                        
                        // Videos section
                        if let user = userViewModel.currentUser {
                            videosSection(user: user)
                        }
                        
                        // Add padding at the bottom to ensure all content is visible
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddVideoSheet) {
            AddVideoView()
                .environmentObject(userViewModel)
        }
    }
    
    // MARK: - View Components
    
    /// Profile header with image, name, and edit buttons
    private var profileHeaderSection: some View {
        ZStack(alignment: .top) {
            // Background image (cover photo)
            ZStack(alignment: .bottomTrailing) {
                if let user = userViewModel.currentUser,
                   let backgroundImage = user.backgroundImage,
                   let uiImage = UIImage(data: backgroundImage) {
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
                
                // Edit cover photo button - now links to EditCoverPhotoView
                NavigationLink(destination: EditCoverPhotoView()) {
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(ScoutColors.primaryBlue)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .padding(12)
            }
            
            VStack {
                Spacer()
                    .frame(height: 70)
                
                // Profile image with camera button positioned like in the screenshot
                ZStack {
                    // Profile image
                    if let user = userViewModel.currentUser,
                       let profileImage = user.profileImage,
                       let uiImage = UIImage(data: profileImage) {
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
                        
                        Text(userViewModel.currentUser?.name.prefix(1) ?? "")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(ScoutColors.primaryBlue)
                    }
                    
                    // Edit profile photo button - positioned like in the screenshot
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: EditProfilePhotoView()) {
                                Circle()
                                    .fill(ScoutColors.primaryBlue)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                            .offset(x: 10, y: 10)
                        }
                    }
                    .frame(width: 100, height: 100)
                }
                
                // Name and spacing
                HStack {
                    Spacer()
                    
                    Text(userViewModel.currentUser?.name ?? "User Name")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
    }
    
    /// Background information section
    private func backgroundSection(user: ScoutModels.User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Background")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                NavigationLink(destination: EditBackgroundView()) {
                    Text("Edit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ScoutColors.primaryBlue)
                }
            }
            
            if !user.backgroundInfo.isEmpty {
                Text(user.backgroundInfo)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Add information about your athletic experience, achievements, and goals.")
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
    
    /// Teams section
    private func teamsSection(user: ScoutModels.User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Teams")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                NavigationLink(destination: EditTeamsView()) {
                    Text("Edit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ScoutColors.primaryBlue)
                }
            }
            
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
                Text("Add teams you've played for or are currently with.")
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
    
    /// Videos section
    private func videosSection(user: ScoutModels.User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Highlight Videos")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                NavigationLink(destination: HighlightsGridView()) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ScoutColors.primaryBlue)
                }
            }
            
            if !user.videos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(user.videos) { video in
                            VideoThumbnail(
                                title: video.title,
                                thumbnailImage: video.thumbnailImage != nil ? UIImage(data: video.thumbnailImage!) : nil,
                                onTap: {
                                    // Handle video tap
                                }
                            )
                            .frame(width: 180)
                        }
                        
                        // Add video button
                        Button(action: {
                            showAddVideoSheet = true
                        }) {
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 120)
                                        .cornerRadius(8)
                                    
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 30))
                                        .foregroundColor(ScoutColors.primaryBlue)
                                }
                                
                                Text("Add Video")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ScoutColors.primaryBlue)
                                    .padding(.top, 4)
                            }
                            .frame(width: 180)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                // Empty state with Add Highlight Video button
                VStack {
                    Button(action: {
                        showAddVideoSheet = true
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 120)
                                .cornerRadius(8)
                            
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(ScoutColors.primaryBlue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white)
                                    )
                                
                                Text("Add Highlight Video")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(ScoutColors.primaryBlue)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    Text("Showcase your athletic abilities with highlight videos")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// MARK: - Previews

struct ProfileSelfView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSelfView()
            .environmentObject(ScoutUserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
