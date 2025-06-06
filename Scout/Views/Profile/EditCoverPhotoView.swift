//
//  EditCoverPhotoView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/20/25.
//

import SwiftUI
import PhotosUI

/// EditCoverPhotoView - Screen for updating the user's cover/background photo
/// Provides landscape image selection with guidelines and preview functionality
struct EditCoverPhotoView: View {
    // MARK: - Environment Properties
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    // MARK: - State Properties
    
    /// Selected image from photo picker
    @State private var selectedImage: UIImage?
    
    /// Photo picker presentation state
    @State private var showingImagePicker = false
    
    /// Action sheet presentation state
    @State private var showingActionSheet = false
    
    /// Loading state for async operations
    @State private var isLoading = false
    
    /// Alert presentation state
    @State private var showAlert = false
    
    /// Alert message content
    @State private var alertMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with back navigation
            ScoutHeader(
                title: "Cover Photo",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 24) {
                    // Cover photo preview and edit section
                    coverPhotoSection
                    
                    // Guidelines section
                    guidelinesSection
                    
                    // Save button (only shown when image is selected)
                    if selectedImage != nil {
                        saveButtonSection
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .actionSheet(isPresented: $showingActionSheet) {
            photoSelectionActionSheet
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Cover Photo"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Navigate back on successful update
                    if alertMessage == "Your cover photo has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - View Components
    
    /// Cover photo display and edit section
    private var coverPhotoSection: some View {
        VStack {
            ZStack {
                // Cover image display
                coverImageView
                
                // Edit button overlay
                editButtonOverlay
            }
            .padding(.top, 20)
            
            // Helper text
            Text("Tap to change cover photo")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    /// Cover image view with fallback
    private var coverImageView: some View {
        Group {
            if let selectedImage = selectedImage {
                // Show selected image
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(8)
            } else if let user = userViewModel.currentUser,
                      let backgroundImage = user.backgroundImage,
                      let uiImage = UIImage(data: backgroundImage) {
                // Show current cover image
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(8)
            } else {
                // Show placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 180)
                    .cornerRadius(8)
                    .overlay(
                        Text("No Cover Photo")
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    /// Edit button overlay
    private var editButtonOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showingActionSheet = true
                }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(ScoutColors.primaryBlue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(16)
            }
        }
    }
    
    /// Guidelines and recommendations section
    private var guidelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cover Photo Recommendations")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                RecommendationRow(text: "Use a high-quality image that represents you as an athlete")
                RecommendationRow(text: "Choose an image that is at least 1200 × 300 pixels")
                RecommendationRow(text: "Keep important content in the center of the image")
            }
            .padding(.horizontal)
        }
        .padding(.top, 16)
    }
    
    /// Save button section
    private var saveButtonSection: some View {
        Button(action: saveCoverPhoto) {
            ZStack {
                // Button text
                Text("Save Changes")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(ScoutColors.primaryBlue)
            .cornerRadius(12)
        }
        .disabled(isLoading)
        .padding(.horizontal)
    }
    
    /// Photo selection action sheet
    private var photoSelectionActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Change Cover Photo"),
            message: Text("How would you like to select a photo?"),
            buttons: [
                .default(Text("Take Photo")) {
                    self.showingImagePicker = true
                },
                .default(Text("Choose from Library")) {
                    self.showingImagePicker = true
                },
                .destructive(Text("Remove Current Photo")) {
                    self.removeCoverPhoto()
                },
                .cancel()
            ]
        )
    }
    
    // MARK: - Methods
    
    /// Saves the selected cover photo to the user model
    private func saveCoverPhoto() {
        guard let image = selectedImage else { return }
        
        // Show loading state
        isLoading = true
        
        // Simulate network upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Convert image to data
            if let imageData = image.jpegData(compressionQuality: 0.8),
               var user = self.userViewModel.currentUser {
                // Update user model
                user.backgroundImage = imageData
                self.userViewModel.updateProfile(updatedUser: user)
                
                // Show success message
                self.alertMessage = "Your cover photo has been updated successfully."
                self.showAlert = true
            } else {
                // Show error message
                self.alertMessage = "Failed to save cover photo. Please try again."
                self.showAlert = true
            }
            
            // Hide loading state
            self.isLoading = false
        }
    }
    
    /// Removes the current cover photo
    private func removeCoverPhoto() {
        // Show loading state
        isLoading = true
        
        // Simulate network request delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if var user = self.userViewModel.currentUser {
                // Clear cover image
                user.backgroundImage = nil
                self.userViewModel.updateProfile(updatedUser: user)
                
                // Clear selected image
                self.selectedImage = nil
                
                // Show success message
                self.alertMessage = "Your cover photo has been removed."
                self.showAlert = true
            }
            
            // Hide loading state
            self.isLoading = false
        }
    }
}

// MARK: - Helper Components

/// Individual recommendation row component
private struct RecommendationRow: View {
    let text: String
    
    var body: some View {
        Text("• \(text)")
            .font(.system(size: 14))
            .foregroundColor(.gray)
    }
}

// MARK: - Preview

struct EditCoverPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        EditCoverPhotoView()
            .environmentObject(ScoutUserViewModel())
    }
}
