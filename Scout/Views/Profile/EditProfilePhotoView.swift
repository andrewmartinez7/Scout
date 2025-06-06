//
//  EditProfilePhotoView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import PhotosUI
import UIKit

/// EditProfilePhotoView - Screen for updating the user's profile photo
/// Provides image selection, preview, and upload functionality
struct EditProfilePhotoView: View {
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
                title: "Profile Photo",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 24) {
                    // Profile photo preview and edit section
                    profilePhotoSection
                    
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
                title: Text("Profile Photo"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Navigate back on successful update
                    if alertMessage == "Your profile photo has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - View Components
    
    /// Profile photo display and edit section
    private var profilePhotoSection: some View {
        VStack {
            ZStack {
                // Profile image display
                profileImageView
                    .frame(width: 150, height: 150)
                
                // Edit button overlay
                editButtonOverlay
            }
            .padding(.top, 20)
            
            // Helper text
            Text("Tap to change profile photo")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    /// Profile image view with fallback
    private var profileImageView: some View {
        Group {
            if let selectedImage = selectedImage {
                // Show selected image
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else if let user = userViewModel.currentUser,
                      let profileImage = user.profileImage,
                      let uiImage = UIImage(data: profileImage) {
                // Show current profile image
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else {
                // Show placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(userViewModel.currentUser?.name.prefix(1) ?? "")
                            .font(.system(size: 60, weight: .semibold))
                            .foregroundColor(.white)
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
                    showingActionSheet = true
                }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(ScoutColors.primaryBlue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
        }
        .padding(8)
        .frame(width: 150, height: 150)
    }
    
    /// Save button section
    private var saveButtonSection: some View {
        Button(action: saveProfilePhoto) {
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
            title: Text("Change Profile Photo"),
            message: Text("How would you like to select a photo?"),
            buttons: [
                .default(Text("Take Photo")) {
                    self.showingImagePicker = true
                },
                .default(Text("Choose from Library")) {
                    self.showingImagePicker = true
                },
                .destructive(Text("Remove Current Photo")) {
                    self.removeProfilePhoto()
                },
                .cancel()
            ]
        )
    }
    
    // MARK: - Methods
    
    /// Saves the selected profile photo to the user model
    private func saveProfilePhoto() {
        guard let image = selectedImage else { return }
        
        // Show loading state
        isLoading = true
        
        // Simulate network upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Convert image to data
            if let imageData = image.jpegData(compressionQuality: 0.8),
               var user = self.userViewModel.currentUser {
                // Update user model
                user.profileImage = imageData
                self.userViewModel.updateProfile(updatedUser: user)
                
                // Show success message
                self.alertMessage = "Your profile photo has been updated successfully."
                self.showAlert = true
            } else {
                // Show error message
                self.alertMessage = "Failed to save profile photo. Please try again."
                self.showAlert = true
            }
            
            // Hide loading state
            self.isLoading = false
        }
    }
    
    /// Removes the current profile photo
    private func removeProfilePhoto() {
        // Show loading state
        isLoading = true
        
        // Simulate network request delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if var user = self.userViewModel.currentUser {
                // Clear profile image
                user.profileImage = nil
                self.userViewModel.updateProfile(updatedUser: user)
                
                // Clear selected image
                self.selectedImage = nil
                
                // Show success message
                self.alertMessage = "Your profile photo has been removed."
                self.showAlert = true
            }
            
            // Hide loading state
            self.isLoading = false
        }
    }
}

// MARK: - Preview

struct EditProfilePhotoView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfilePhotoView()
            .environmentObject(ScoutUserViewModel())
    }
}
