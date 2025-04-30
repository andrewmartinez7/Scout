//
//  EditProfilePhotoView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//
import SwiftUI
import PhotosUI

/// EditProfilePhotoView - Screen for updating the user's profile photo
struct EditProfilePhotoView: View {
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
            ScoutHeader(
                title: "Profile Photo",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
              
            ScrollView {
                VStack(spacing: 24) {
                    // Current profile photo
                    VStack {
                        ZStack {
                            // Profile image
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else if let user = userViewModel.currentUser,
                                      let profileImage = user.profileImage,
                                      let uiImage = UIImage(data: profileImage) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: 150)
                                  
                                Text(userViewModel.currentUser?.name.prefix(1) ?? "")
                                    .font(.system(size: 60, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                              
                            // Edit button
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
                        .padding(.top, 20)
                          
                        Text("Tap to change profile photo")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal)
                      
                    // Save button
                    if selectedImage != nil {
                        Button(action: saveProfilePhoto) {
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Profile Photo"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Your profile photo has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
      
    // MARK: - Methods
    
    /// Save the selected profile photo to the user model
    private func saveProfilePhoto() {
        guard let image = selectedImage else { return }
          
        // Show loading indicator
        isLoading = true
          
        // Simulate network delay
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
              
            // Hide loading indicator
            self.isLoading = false
        }
    }
      
    /// Remove the current profile photo
    private func removeProfilePhoto() {
        // Show loading indicator
        isLoading = true
          
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if var user = self.userViewModel.currentUser {
                // Update user model
                user.profileImage = nil
                self.userViewModel.updateProfile(updatedUser: user)
                  
                // Clear selected image
                self.selectedImage = nil
                  
                // Show success message
                self.alertMessage = "Your profile photo has been removed."
                self.showAlert = true
            }
              
            // Hide loading indicator
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
