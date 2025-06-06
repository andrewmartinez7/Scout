//
//  RegisterView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

/// RegisterView - Screen for creating new user accounts
/// Provides form-based registration with validation and error handling
struct RegisterView: View {
    // MARK: - Environment and State Properties
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    // Form input states
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // UI state management
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Design Constants
    
    /// Consistent corner radius for form elements
    private let cornerRadius: CGFloat = 12
    
    /// Standard button height following iOS design guidelines
    private let buttonHeight: CGFloat = 55
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with back navigation
            ScoutHeader(
                title: "Create Account",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome text section
                    welcomeSection
                    
                    // Registration form fields
                    registrationFormSection
                    
                    // Create account button
                    createAccountButtonSection
                    
                    // Terms and conditions text
                    termsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Registration"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Navigate back to login on successful registration
                    if alertMessage == "Account created successfully! Please log in." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - View Components
    
    /// Welcome message section
    private var welcomeSection: some View {
        Text("Enter your information to create an account")
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 20)
    }
    
    /// Registration form with input fields
    private var registrationFormSection: some View {
        VStack(spacing: 16) {
            // Full name input field
            FormInputField(
                title: "Full Name",
                text: $name,
                placeholder: "Enter your full name"
            )
            
            // Email input field
            FormInputField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email address",
                keyboardType: .emailAddress,
                autocapitalization: .none,
                disableAutocorrection: true
            )
            
            // Password input field
            SecureFormInputField(
                title: "Password",
                text: $password,
                placeholder: "Create a password"
            )
            
            // Confirm password input field
            SecureFormInputField(
                title: "Confirm Password",
                text: $confirmPassword,
                placeholder: "Confirm your password"
            )
        }
    }
    
    /// Create account button section
    private var createAccountButtonSection: some View {
        Button(action: register) {
            ZStack {
                // Button text
                Text("Create Account")
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
            .frame(height: buttonHeight)
            .background(
                isFormValid ? ScoutColors.primaryBlue : ScoutColors.primaryBlue.opacity(0.5)
            )
            .cornerRadius(cornerRadius)
        }
        .disabled(!isFormValid || isLoading)
    }
    
    /// Terms and conditions section
    private var termsSection: some View {
        Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    
    /// Validates all form fields for registration requirements
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty && email.contains("@") &&
        !password.isEmpty && password.count >= 6 &&
        password == confirmPassword
    }
    
    // MARK: - Actions
    
    /// Handles user registration process
    private func register() {
        // Show loading state
        isLoading = true
        
        // Simulate network registration delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Create new user model
            let newUser = ScoutModels.User(
                id: UUID().uuidString,
                name: self.name,
                email: self.email,
                profileImage: nil,
                backgroundImage: nil,
                backgroundInfo: "",
                teams: [],
                videos: []
            )
            
            // Add user to the system
            self.userViewModel.users.append(newUser)
            
            // Show success message
            self.alertMessage = "Account created successfully! Please log in."
            self.isLoading = false
            self.showAlert = true
        }
    }
}

// MARK: - Helper Components

/// Reusable form input field component
private struct FormInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    var disableAutocorrection: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ScoutColors.textGray)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 17))
                .padding(16)
                .background(ScoutColors.inputBackground)
                .cornerRadius(12)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .disableAutocorrection(disableAutocorrection)
        }
    }
}

/// Reusable secure form input field component
private struct SecureFormInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ScoutColors.textGray)
            
            SecureField(placeholder, text: $text)
                .font(.system(size: 17))
                .padding(16)
                .background(ScoutColors.inputBackground)
                .cornerRadius(12)
        }
    }
}

// MARK: - Preview

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(ScoutUserViewModel())
    }
}
