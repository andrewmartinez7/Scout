//
//  EditCoverPhotoView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/20/25.
//
import SwiftUI
import PhotosUI
import UIKit // Add UIKit import

/// EditCoverPhotoView - Screen for updating the user's cover/background photo
struct EditCoverPhotoView: View {
    // MARK: - Properties
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
      
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
      
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScoutHeader(
                title: "Cover Photo",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
              
            ScrollView {
                VStack(spacing: 24) {
                    // Current cover photo
                    VStack {
                        ZStack {
                            // Cover image preview
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(8)
                            } else if let user = userViewModel.currentUser,
                                     let backgroundImage = user.backgroundImage,
                                     let uiImage = UIImage(data: backgroundImage) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 180)
                                    .cornerRadius(8)
                                  
                                Text("No Cover Photo")
                                    .foregroundColor(.gray)
                            }
                              
                            // Edit button
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
                        .padding(.top, 20)
                          
                        Text("Tap to change cover photo")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal)
                      
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cover Photo Recommendations")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal)
                          
                        Text("• Use a high-quality image that represents you as an athlete")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                          
                        Text("• Choose an image that is at least 1200 × 300 pixels")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                          
                        Text("• Keep important content in the center of the image")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                      
                    // Save button
                    if selectedImage != nil {
                        Button(action: saveCoverPhoto) {
                            ZStack {
                                Text("Save Changes")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .opacity(isLoading ? 0 : 1)
                                  
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
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .actionSheet(isPresented: $showingActionSheet) {
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Cover Photo"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Your cover photo has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
      
    // MARK: - Methods
    
    /// Save the selected cover photo to the user model
    private func saveCoverPhoto() {
        guard let image = selectedImage else { return }
          
        // Show loading indicator
        isLoading = true
          
        // Simulate network delay
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
              
            // Hide loading indicator
            self.isLoading = false
        }
    }
      
    /// Remove the current cover photo
    private func removeCoverPhoto() {
        // Show loading indicator
        isLoading = true
          
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if var user = self.userViewModel.currentUser {
                // Update user model
                user.backgroundImage = nil
                self.userViewModel.updateProfile(updatedUser: user)
                  
                // Clear selected image
                self.selectedImage = nil
                  
                // Show success message
                self.alertMessage = "Your cover photo has been removed."
                self.showAlert = true
            }
              
            // Hide loading indicator
            self.isLoading = false
        }
    }
}

// MARK: - Preview

struct EditCoverPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        EditCoverPhotoView()
            .environmentObject(ScoutUserViewModel())
    }
}
