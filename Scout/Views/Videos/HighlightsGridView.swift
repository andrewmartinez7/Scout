//
//  HighlightsGridView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/21/25.
//

import SwiftUI
import PhotosUI

/// HighlightsGridView - Grid display of user's highlight videos
/// Provides organized video browsing with add video functionality
struct HighlightsGridView: View {
    // MARK: - Environment Properties
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    // MARK: - State Properties
    
    /// Add video sheet presentation state
    @State private var showAddVideoSheet = false
    
    // MARK: - Layout Configuration
    
    /// Grid layout with two flexible columns
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with back navigation
            ScoutHeader(
                title: "Highlight Videos",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // Main content area
            mainContentView
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showAddVideoSheet) {
            AddVideoView()
                .environmentObject(userViewModel)
        }
    }
    
    // MARK: - View Components
    
    /// Main content view with conditional display
    @ViewBuilder
    private var mainContentView: some View {
        if let user = userViewModel.currentUser {
            if user.videos.isEmpty {
                emptyStateView
            } else {
                videosGridView
            }
        } else {
            loadingView
        }
    }
    
    /// Loading state view
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    /// Empty state when no videos exist
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Empty state icon
            Image(systemName: "video.fill")
                .font(.system(size: 60))
                .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
            
            // Title
            Text("No Highlight Videos")
                .font(.system(size: 20, weight: .semibold))
            
            // Subtitle
            Text("Showcase your athletic abilities with highlight videos")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Add video button
            Button(action: {
                showAddVideoSheet = true
            }) {
                Text("Add Video")
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
    }
    
    /// Grid view displaying videos
    private var videosGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                // Existing videos
                ForEach(userViewModel.currentUser?.videos ?? []) { video in
                    NavigationLink(destination: VideoPlayerView(video: video)) {
                        VideoThumbnail(
                            title: video.title,
                            thumbnailImage: video.thumbnailImage != nil ? UIImage(data: video.thumbnailImage!) : nil,
                            onTap: {
                                // Navigation handled by NavigationLink
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Add video button
                addVideoGridItem
            }
            .padding()
        }
    }
    
    /// Add video button for grid
    private var addVideoGridItem: some View {
        Button(action: {
            showAddVideoSheet = true
        }) {
            VStack {
                ZStack {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(8)
                    
                    // Plus icon
                    Circle()
                        .fill(ScoutColors.primaryBlue)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                
                // Button label
                Text("Add Video")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ScoutColors.primaryBlue)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Preview

struct HighlightsGridView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightsGridView()
            .environmentObject(ScoutUserViewModel())
    }
}
