//
//  ChangePasswordView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScoutHeader(
                title: "Change Password",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Current password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ScoutColors.textGray)
                        
                        SecureField("", text: $currentPassword)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // New password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ScoutColors.textGray)
                        
                        SecureField("", text: $newPassword)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            
                        // Password requirements
                        if !newPassword.isEmpty {
                            passwordRequirementsView
                        }
                    }
                    
                    // Confirm password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm New Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ScoutColors.textGray)
                        
                        SecureField("", text: $confirmPassword)
                            .font(.system(size: 17))
                            .padding(16)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            
                        // Show match status
                        if !confirmPassword.isEmpty {
                            HStack {
                                Image(systemName: newPassword == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(newPassword == confirmPassword ? .green : .red)
                                
                                Text(newPassword == confirmPassword ? "Passwords match" : "Passwords don't match")
                                    .font(.system(size: 12))
                                    .foregroundColor(newPassword == confirmPassword ? .green : .red)
                            }
                        }
                    }
                    
                    // Update button
                    Button(action: updatePassword) {
                        ZStack {
                            Text("Update Password")
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Change Password"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // If success, go back
                    if alertMessage == "Your password has been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // Password requirements view
    private var passwordRequirementsView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Password must:")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            passwordRequirementRow(
                text: "Be at least 8 characters long",
                isMet: newPassword.count >= 8
            )
            
            passwordRequirementRow(
                text: "Include at least one uppercase letter",
                isMet: newPassword.contains(where: { $0.isUppercase })
            )
            
            passwordRequirementRow(
                text: "Include at least one number",
                isMet: newPassword.contains(where: { $0.isNumber })
            )
        }
    }
    
    // Single password requirement row
    private func passwordRequirementRow(text: String, isMet: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .gray)
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        return !currentPassword.isEmpty
            && newPassword.count >= 8
            && newPassword.contains(where: { $0.isUppercase })
            && newPassword.contains(where: { $0.isNumber })
            && newPassword == confirmPassword
    }
    
    // Update password
    private func updatePassword() {
        // Show loading indicator
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real app, this would validate with a backend service
            // For now, we'll just simulate success if the current password is at least 6 chars
            if self.currentPassword.count >= 6 {
                self.alertMessage = "Your password has been updated successfully."
            } else {
                self.alertMessage = "Incorrect current password. Please try again."
            }
            
            // Hide loading indicator and show result
            self.isLoading = false
            self.showAlert = true
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(ScoutUserViewModel())
    }
}
