//
//  ChangeEmailView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI
import UIKit // Add UIKit import

struct ChangeEmailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    @State private var currentEmail = ""
    @State private var newEmail = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScoutHeader(
                title: "Change Email",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Current email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ScoutColors.textGray)
                        
                        TextField("", text: $currentEmail)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(ScoutColors.inputBackground)
                            .cornerRadius(12)
                            .disabled(true)
                    }
                    
                    // New email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ScoutColors.textGray)
                        
                        TextField("", text: $newEmail)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(ScoutColors.inputBackground)
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Password for verification
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ScoutColors.textGray)
                        
                        SecureField("", text: $password)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(ScoutColors.inputBackground)
                            .cornerRadius(12)
                    }
                    
                    // Update button
                    Button(action: updateEmail) {
                        ZStack {
                            Text("Update Email")
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
                        .background(
                            isFormValid ? ScoutColors.primaryBlue : ScoutColors.primaryBlue.opacity(0.5)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            // Load current email
            if let user = userViewModel.currentUser {
                currentEmail = user.email
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Change Email"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // If success, go back
                    if alertMessage == "Your email has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        return !newEmail.isEmpty && newEmail.contains("@") && !password.isEmpty && newEmail != currentEmail
    }
    
    // Update email
    private func updateEmail() {
        // Show loading indicator
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real app, this would validate with a backend service
            // For now, we'll just update the local model
            if self.password.count >= 6 {
                if var user = self.userViewModel.currentUser {
                    user.email = self.newEmail
                    self.userViewModel.updateProfile(updatedUser: user)
                    self.alertMessage = "Your email has been updated successfully."
                }
            } else {
                self.alertMessage = "Incorrect password. Please try again."
            }
            
            // Hide loading indicator and show result
            self.isLoading = false
            self.showAlert = true
        }
    }
}

struct ChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailView()
            .environmentObject(ScoutUserViewModel())
    }
}
