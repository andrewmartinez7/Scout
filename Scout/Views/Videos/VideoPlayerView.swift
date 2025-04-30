//
//  VideoPlayerView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    let video: ScoutModels.Video
    
    // State for video player
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            ZStack {
                Rectangle()
                    .fill(Color.black)
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
                    
                    // Title
                    Text(video.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Share button
                    Button(action: {
                        // Share functionality
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    .padding(.trailing, 8)
                }
                .padding(.top, 40) // For safe area
            }
            
            // Video player
            ZStack {
                // Video
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(16/9, contentMode: .fit)
                        .onAppear {
                            // Auto-play when view appears
                            player.play()
                            isPlaying = true
                            
                            // Simulate loading finished
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isLoading = false
                            }
                        }
                        .onDisappear {
                            // Pause when view disappears
                            player.pause()
                        }
                } else {
                    // Placeholder
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fit)
                }
                
                // Loading overlay
                if isLoading {
                    Rectangle()
                        .fill(Color.black.opacity(0.7))
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            
            // Video info
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Video title and date
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.title)
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(formatDate(video.uploadDate))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Video description (placeholder in this demo)
                    Text("This highlight video showcases athletic performance and skills. It provides coaches and recruiters with a visual demonstration of abilities, techniques, and competitive performance.")
                        .font(.system(size: 15))
                        .lineSpacing(4)
                    
                    // Stats section (placeholder in this demo)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stats")
                            .font(.system(size: 18, weight: .semibold))
                        
                        statsRow(stat: "Views", value: "328")
                        statsRow(stat: "Length", value: "2:45")
                        statsRow(stat: "Uploaded", value: formatDate(video.uploadDate))
                    }
                    .padding(.top, 8)
                    
                    // Actions
                    HStack(spacing: 20) {
                        Button(action: {
                            // Share functionality
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                
                                Text("Share")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(ScoutColors.primaryBlue)
                        }
                        
                        Button(action: {
                            // Download functionality
                        }) {
                            VStack {
                                Image(systemName: "arrow.down.circle")
                                    .font(.system(size: 20))
                                
                                Text("Download")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(ScoutColors.primaryBlue)
                        }
                        
                        Button(action: {
                            // Edit functionality
                        }) {
                            VStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20))
                                
                                Text("Edit")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(ScoutColors.primaryBlue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: setupPlayer)
    }
    
    // Setup the video player
    private func setupPlayer() {
        // In a real app, we would use the video.url
        // For this demo, we'll use a sample video URL
        if let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
            player = AVPlayer(url: url)
        }
    }
    
    // Format date string
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Stats row helper
    private func statsRow(stat: String, value: String) -> some View {
        HStack {
            Text(stat)
                .font(.system(size: 15))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
        }
        .padding(.vertical, 4)
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample video for preview
        let sampleVideo = ScoutModels.Video(
            id: "1",
            title: "Football Highlights 2024",
            thumbnailImage: nil,
            url: nil,
            uploadDate: Date()
        )
        
        return VideoPlayerView(video: sampleVideo)
    }
}
