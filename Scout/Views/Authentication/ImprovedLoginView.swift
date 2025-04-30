//
//  ImprovedLoginView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/20/25.
//

import SwiftUI

/// ImprovedLoginView - Enhanced authentication entry point for the Scout app
/// This view handles user login functionality with email/password and social options
struct ImprovedLoginView: View {
    // MARK: - Properties
    
    // Environment objects and state variables
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // Constants for design consistency
    private let cornerRadius: CGFloat = 12
    private let shadowRadius: CGFloat = 3
    private let buttonHeight: CGFloat = 55
    private let horizontalPadding: CGFloat = 24
    
    // MARK: - Body
    
    var body: some View {
        // Using ScrollView for better handling on smaller screens
        ScrollView {
            VStack {
                // Main content container
                VStack(spacing: 0) {
                    // Welcome section with increased top padding
                    welcomeSection
                        .padding(.top, 100)
                        .padding(.bottom, 40)
                    
                    // Login form section
                    loginFormSection
                        .padding(.bottom, 32)
                    
                    // Divider section
                    dividerSection
                        .padding(.bottom, 32)
                    
                    // Social login section
                    socialLoginSection
                        .padding(.bottom, 24) // Reduced to make room for sign up moving up
                }
                .padding(.horizontal, horizontalPadding)
                
                // Sign up section - Moved outside the main VStack to position it independently
                signUpSection
                    .padding(.top, 0) // No top padding needed now
                    .padding(.bottom, 20) // Reduced bottom padding
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .overlay(
            // Loading overlay
            loadingOverlay
                .opacity(isLoading ? 1 : 0)
        )
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - View Components
    
    /// Welcome message and app description
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Text("Welcome to Scout")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("Connect with athletes and coaches")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Email and password input fields with login button
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("", text: $email)
                    .font(.system(size: 17))
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(cornerRadius)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                SecureField("", text: $password)
                    .font(.system(size: 17))
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(cornerRadius)
            }
            
            // Forgot password link
            HStack {
                Spacer()
                Button(action: {
                    // Handle forgot password action
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ScoutColors.primaryBlue)
                }
            }
            .padding(.top, 4)
            
            // Login button
            Button(action: handleLogin) {
                Text("Log In")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .background(ScoutColors.primaryBlue)
                    .cornerRadius(cornerRadius)
                    .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
            }
            .padding(.top, 12)
        }
    }
    
    /// Divider with "OR" text
    private var dividerSection: some View {
        HStack {
            VStack { Divider() }.padding(.trailing, 8)
            Text("OR")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            VStack { Divider() }.padding(.leading, 8)
        }
    }
    
    /// Social login options
    private var socialLoginSection: some View {
        VStack(spacing: 16) {
            // Facebook login
            socialLoginButton(
                text: "Continue with Facebook",
                icon: Image(systemName: "f.circle.fill"),
                iconColor: Color.white,
                backgroundColor: ScoutColors.facebookBlue,
                action: handleFacebookLogin
            )
            
            // Apple login
            socialLoginButton(
                text: "Continue with Apple",
                icon: Image(systemName: "apple.logo"),
                iconColor: Color.white,
                backgroundColor: ScoutColors.appleBlack,
                action: handleAppleLogin
            )
            
            // Email signup
            socialLoginButton(
                text: "Continue with Email",
                icon: Image(systemName: "envelope.fill"),
                iconColor: Color.black,
                backgroundColor: Color(.systemGray6),
                textColor: Color.black,
                action: handleEmailSignup
            )
        }
    }
    
    /// Reusable social login button component
    private func socialLoginButton(
        text: String,
        icon: Image,
        iconColor: Color,
        backgroundColor: Color,
        textColor: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconColor)
                    .padding(.leading, 16)
                
                Spacer()
                
                Text(text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
            }
            .frame(height: buttonHeight)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
        }
    }
    
    /// Sign up link for new users
    private var signUpSection: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            
            Button(action: {
                // Navigate to sign up screen
            }) {
                Text("Sign Up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ScoutColors.primaryBlue)
            }
        }
    }
    
    /// Loading overlay with activity indicator
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Logging in...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 12)
            }
            .padding(24)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Actions
    
    /// Handle email/password login
    private func handleLogin() {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password."
            showAlert = true
            return
        }
        
        // Show loading indicator
        isLoading = true
        
        // Simulate login process (replace with actual authentication)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // For testing, always succeed if input is valid
            if email.contains("@") {
                self.userViewModel.login(email: self.email, password: self.password)
            } else {
                self.alertMessage = "Please enter a valid email address."
                self.showAlert = true
            }
        }
    }
    
    /// Handle Facebook login
    private func handleFacebookLogin() {
        // Implement Facebook authentication
        print("Facebook login tapped")
    }
    
    /// Handle Apple login
    private func handleAppleLogin() {
        // Implement Apple authentication
        print("Apple login tapped")
    }
    
    /// Handle email signup navigation
    private func handleEmailSignup() {
        // Navigate to email signup flow
        print("Email signup tapped")
    }
}

// MARK: - Preview
struct ImprovedLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ImprovedLoginView()
            .environmentObject(ScoutUserViewModel())
    }
}
