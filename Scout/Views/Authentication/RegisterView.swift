//
//  RegisterView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Constants for design consistency
    private let cornerRadius: CGFloat = 12
    private let buttonHeight: CGFloat = 55
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScoutHeader(
                title: "Create Account",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Information text
                    Text("Enter your information to create an account")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    // Registration form
                    VStack(spacing: 16) {
                        // Name field
                        inputField(title: "Full Name", text: $name, keyboardType: .default)
                        
                        // Email field
                        inputField(title: "Email", text: $email, keyboardType: .emailAddress)
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ScoutColors.textGray)
                            
                            SecureField("", text: $password)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(cornerRadius)
                        }
                        
                        // Confirm password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ScoutColors.textGray)
                            
                            SecureField("", text: $confirmPassword)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(cornerRadius)
                        }
                    }
                    
                    // Register button
                    Button(action: register) {
                        ZStack {
                            Text("Create Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)
                            
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
                    
                    // Terms text
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
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
                    // If registration was successful, go back to login
                    if alertMessage == "Account created successfully! Please log in." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // Reusable input field
    private func inputField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ScoutColors.textGray)
            
            TextField("", text: text)
                .font(.system(size: 17))
                .padding(16)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(cornerRadius)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty && email.contains("@") &&
        !password.isEmpty && password.count >= 6 &&
        password == confirmPassword
    }
    
    // Register function
    private func register() {
        // Show loading indicator
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real app, this would register with a backend service
            // For now, we'll just simulate success
            
            // Create a new user
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
            
            // Add to users
            self.userViewModel.users.append(newUser)
            
            // Show success message
            self.alertMessage = "Account created successfully! Please log in."
            self.isLoading = false
            self.showAlert = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(ScoutUserViewModel())
    }
}
