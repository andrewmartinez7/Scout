// HighlightsGridView.swift

import SwiftUI
import PhotosUI

struct HighlightsGridView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    @State private var showAddVideoSheet = false
    
    // Grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScoutHeader(
                title: "Highlight Videos",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            if let user = userViewModel.currentUser {
                if user.videos.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Videos grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(user.videos) { video in
                                VideoThumbnail(
                                    title: video.title,
                                    thumbnailImage: video.thumbnailImage != nil ? UIImage(data: video.thumbnailImage!) : nil,
                                    onTap: {
                                        // Handle video tap
                                    }
                                )
                            }
                            
                            // Add video button
                            addVideoButton
                        }
                        .padding()
                    }
                }
            } else {
                // Loading view
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showAddVideoSheet) {
            AddVideoView()
                .environmentObject(userViewModel)
        }
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "video.fill")
                .font(.system(size: 60))
                .foregroundColor(ScoutColors.primaryBlue.opacity(0.5))
            
            Text("No Highlight Videos")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Showcase your athletic abilities with highlight videos")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
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
    
    // Add video button
    private var addVideoButton: some View {
        Button(action: {
            showAddVideoSheet = true
        }) {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(8)
                    
                    Circle()
                        .fill(ScoutColors.primaryBlue)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                
                Text("Add Video")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ScoutColors.primaryBlue)
                    .padding(.top, 4)
            }
        }
    }
}
