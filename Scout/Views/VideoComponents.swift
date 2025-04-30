//
//  VideoComponents.swift
//  Scout
//
//  Created by Andrew Martinez on 4/21/25.
//

// VideoComponents.swift
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Video Picker

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie, UTType.video, UTType.audiovisualContent])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Get file size to check against the 100MB limit
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
                if let fileSize = fileAttributes[.size] as? NSNumber {
                    let fileSizeMB = fileSize.intValue / (1024 * 1024)
                    
                    if fileSizeMB <= 100 {
                        parent.selectedURL = url
                    } else {
                        // File too large, handle this case in a real app
                        print("File too large: \(fileSizeMB)MB")
                    }
                }
            } catch {
                print("Error getting file size: \(error)")
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Add Video View

struct AddVideoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    @State private var videoTitle = ""
    @State private var selectedVideoURL: URL? = nil
    @State private var showVideoPicker = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Video title field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Video Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter a title for your video", text: $videoTitle)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Upload section matching screenshot
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upload Video")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            // Video icon
                            Image(systemName: "video.fill")
                                .font(.system(size: 24))
                                .foregroundColor(ScoutColors.primaryBlue)
                                .frame(width: 36, height: 36)
                            
                            // Text
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select a video from your device")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                
                                Text("Maximum size: 100MB")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Browse button
                            Button(action: {
                                showVideoPicker = true
                            }) {
                                Text("Browse")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(ScoutColors.primaryBlue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Selected video preview (if available)
                    if selectedVideoURL != nil {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text("Video selected")
                                .foregroundColor(.green)
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    
                    // Upload button
                    Button(action: uploadVideo) {
                        ZStack {
                            Text("Upload Video")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? ScoutColors.primaryBlue : ScoutColors.primaryBlue.opacity(0.5))
                        .cornerRadius(8)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.top, 16)
                }
                .padding()
            }
            .navigationBarTitle("Add Highlight Video", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Video Upload"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("successful") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(selectedURL: $selectedVideoURL)
            }
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        return !videoTitle.isEmpty && selectedVideoURL != nil
    }
    
    // Upload video function
    private func uploadVideo() {
        guard let videoURL = selectedVideoURL, !videoTitle.isEmpty else { return }
        
        isLoading = true
        
        // Simulate network delay for uploading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // In a real app, this would upload to a server
            // For now, create a mock video
            if var user = self.userViewModel.currentUser {
                // Create a new video
                let newVideo = ScoutModels.Video(
                    id: UUID().uuidString,
                    title: self.videoTitle,
                    thumbnailImage: nil, // In a real app, we would generate a thumbnail
                    url: videoURL,
                    uploadDate: Date()
                )
                
                // Add to user's videos
                user.videos.append(newVideo)
                self.userViewModel.updateProfile(updatedUser: user)
                
                self.alertMessage = "Video uploaded successfully!"
            } else {
                self.alertMessage = "Failed to upload video. Please try again."
            }
            
            self.isLoading = false
            self.showAlert = true
        }
    }
}
