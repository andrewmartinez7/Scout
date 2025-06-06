//
//  ScoutComponents.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import PhotosUI

/// ScoutComponents - Reusable UI components for the Scout app
/// Contains common components used throughout the application

// MARK: - ScoutHeader

/// ScoutHeader - A reusable header component used throughout the app
/// Provides consistent navigation and branding across screens
struct ScoutHeader: View {
    // MARK: - Properties
    
    /// Title text displayed in the header
    var title: String
    
    /// Whether to show a back navigation button
    var hasBackButton: Bool = false
    
    /// Callback for back button tap
    var onBackTapped: (() -> Void)? = nil
    
    // MARK: - Body
    
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

// MARK: - VideoThumbnail

/// VideoThumbnail - A reusable component for displaying video thumbnails
/// Shows video preview with play button and title
struct VideoThumbnail: View {
    // MARK: - Properties
    
    /// Video title
    var title: String
    
    /// Optional thumbnail image
    var thumbnailImage: UIImage?
    
    /// Tap callback
    var onTap: () -> Void
    
    // MARK: - Body
    
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

// MARK: - UserListItem

/// UserListItem - A reusable component for displaying user information in lists
/// Shows user avatar, name, and team information
struct UserListItem: View {
    // MARK: - Properties
    
    /// User data to display
    var user: ScoutModels.User
    
    /// Tap callback
    var onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image
                UserAvatarView(user: user, size: 50)
                
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
            .contentShape(Rectangle()) // Make entire row tappable
        }
    }
}

// MARK: - UserAvatarView

/// UserAvatarView - Displays user profile image or initials fallback
/// Reusable component for consistent avatar display
struct UserAvatarView: View {
    // MARK: - Properties
    
    /// User data
    let user: ScoutModels.User
    
    /// Avatar size
    let size: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if let profileImage = user.profileImage,
               let uiImage = UIImage(data: profileImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: size * 0.4, weight: .semibold))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}

// MARK: - RoundedButton

/// RoundedButton - A reusable button with consistent styling
/// Provides primary and secondary button styles
struct RoundedButton: View {
    // MARK: - Properties
    
    /// Button title
    var title: String
    
    /// Button action
    var action: () -> Void
    
    /// Whether this is a primary button (filled) or secondary (outlined)
    var isPrimary: Bool = true
    
    // MARK: - Body
    
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

// MARK: - ImagePicker

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
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
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
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
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
            if let itemProvider = results.first?.itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self) {
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
