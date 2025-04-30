//
//  ScoutComponents.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//
import SwiftUI
import PhotosUI

/// ScoutHeader - A reusable header component used throughout the app
struct ScoutHeader: View {
    var title: String
    var hasBackButton: Bool = false
    var onBackTapped: (() -> Void)? = nil
      
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(ScoutColors.primaryBlue)
                .frame(height: 90)
                .edgesIgnoringSafeArea(.top)
              
            // Content
            HStack {
                // Back button if needed
                if hasBackButton {
                    Button(action: {
                        onBackTapped?()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(8)
                    }
                    .padding(.leading, 8)
                }
                  
                Spacer()
                  
                // Title
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                  
                Spacer()
                  
                // Empty space to balance the back button
                if hasBackButton {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 10)
                }
            }
            .padding(.top, 40) // Account for status bar
        }
    }
}

/// VideoThumbnail - A reusable component for displaying video thumbnails
struct VideoThumbnail: View {
    var title: String
    var thumbnailImage: UIImage?
    var onTap: () -> Void
      
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading) {
                // Thumbnail
                ZStack {
                    if let thumbnailImage = thumbnailImage {
                        Image(uiImage: thumbnailImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 120)
                            .cornerRadius(8)
                          
                        Image(systemName: "play.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                .clipped()
                  
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
    }
}

/// UserListItem - A reusable component for displaying user information in lists
struct UserListItem: View {
    var user: ScoutModels.User
    var onTap: () -> Void
      
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image
                ZStack {
                    if let profileImage = user.profileImage, let uiImage = UIImage(data: profileImage) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                          
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                  
                // User info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                      
                    if !user.teams.isEmpty {
                        Text(user.teams.joined(separator: ", "))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                  
                Spacer()
                  
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}

/// RoundedButton - A reusable button with consistent styling
struct RoundedButton: View {
    var title: String
    var action: () -> Void
    var isPrimary: Bool = true
      
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(isPrimary ? .white : ScoutColors.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isPrimary ? ScoutColors.primaryBlue : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isPrimary ? Color.clear : ScoutColors.primaryBlue, lineWidth: 1)
                )
        }
    }
}

/// ImagePicker - A reusable component for selecting images from the photo library
/// Used consistently across the app for profile and cover photo selection
struct ImagePicker: UIViewControllerRepresentable {
    // MARK: - Properties
    
    /// The selected image binding that will be updated when user picks an image
    @Binding var image: UIImage?
    
    /// Environment to dismiss the picker when finished
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - UIViewControllerRepresentable
    
    /// Creates and configures the PHPickerViewController
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Configure the picker options
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        // Create and setup the picker
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    /// Updates the view controller if needed (not used in this implementation)
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    /// Creates a coordinator to handle the picker delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /// Coordinator class to act as delegate for PHPickerViewController
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        /// Reference to parent ImagePicker
        let parent: ImagePicker
        
        /// Initialize with parent reference
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Handle the picker result when user finishes picking
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Load the image if available
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        // Update on main thread
                        DispatchQueue.main.async {
                            self.parent.image = image
                        }
                    }
                }
            }
            
            // Dismiss the picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
