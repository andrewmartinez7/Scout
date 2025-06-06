//
//  ChangeEmailView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

/// ChangeEmailView - Screen for updating user's email address
/// Provides secure email change functionality with password verification
struct ChangeEmailView: View {
    // MARK: - Environment Properties
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    // MARK: - State Properties
    
    /// Current email address (read-only)
    @State private var currentEmail = ""
    
    /// New email address input
    @State private var newEmail = ""
    
    /// Password for verification
    @State private var password = ""
    
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
                title: "Change Email",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 24) {
                    // Current email display field
                    currentEmailSection
                    
                    // New email input field
                    newEmailSection
                    
                    // Password verification field
                    passwordSection
                    
                    // Update button
                    updateButtonSection
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            loadCurrentEmail()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Change Email"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Navigate back on successful update
                    if alertMessage == "Your email has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - View Components
    
    /// Current email display section
    private var currentEmailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Email")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ScoutColors.textGray)
            
            TextField("Loading...", text: $currentEmail)
                .font(.system(size: 17))
                .padding(16)
                .background(ScoutColors.inputBackground)
                .cornerRadius(12)
                .disabled(true)
        }
    }
    
    /// New email input section
    private var newEmailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Email")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ScoutColors.textGray)
            
            TextField("Enter your new email address", text: $newEmail)
                .font(.system(size: 17))
                .padding(16)
                .background(ScoutColors.inputBackground)
                .cornerRadius(12)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }
    
    /// Password verification section
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ScoutColors.textGray)
            
            SecureField("Enter your current password", text: $password)
                .font(.system(size: 17))
                .padding(16)
                .background(ScoutColors.inputBackground)
                .cornerRadius(12)
        }
    }
    
    /// Update button section
    private var updateButtonSection: some View {
        Button(action: updateEmail) {
            ZStack {
                // Button text
                Text("Update Email")
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
            .background(
                isFormValid ? ScoutColors.primaryBlue : ScoutColors.primaryBlue.opacity(0.5)
            )
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isLoading)
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    
    /// Validates form inputs for email update
    private var isFormValid: Bool {
        return !newEmail.isEmpty &&
               newEmail.contains("@") &&
               !password.isEmpty &&
               newEmail != currentEmail
    }
    
    // MARK: - Methods
    
    /// Loads the current user's email address
    private func loadCurrentEmail() {
        if let user = userViewModel.currentUser {
            currentEmail = user.email
        }
    }
    
    /// Handles email update process
    private func updateEmail() {
        // Show loading state
        isLoading = true
        
        // Simulate network request delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Validate password (simplified for demo)
            if self.password.count >= 6 {
                if var user = self.userViewModel.currentUser {
                    // Update user email
                    user.email = self.newEmail
                    self.userViewModel.updateProfile(updatedUser: user)
                    self.alertMessage = "Your email has been updated successfully."
                }
            } else {
                self.alertMessage = "Incorrect password. Please try again."
            }
            
            // Hide loading and show result
            self.isLoading = false
            self.showAlert = true
        }
    }
}

// MARK: - Preview

struct ChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailView()
            .environmentObject(ScoutUserViewModel())
    }
}
