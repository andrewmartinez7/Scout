//
//  EditBackgroundView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

struct EditBackgroundView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @State private var backgroundText = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScoutHeader(
                title: "Edit Background",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            VStack(spacing: 24) {
                // Text editor
                TextEditor(text: $backgroundText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(height: 200)
                    .padding(.top, 16)
                
                // Help text
                Text("Describe your athletic experience, achievements, stats, and goals. This helps coaches learn more about you.")
                    .font(.footnote)
                    .foregroundColor(ScoutColors.textGray)
                
                Button(action: {
                    // Save the background info
                    if !backgroundText.isEmpty {
                        saveBackgroundInfo()
                        showAlert = true
                    }
                }) {
                    Text("Save Changes")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ScoutColors.primaryBlue)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            // Load current background text
            if let user = userViewModel.currentUser {
                backgroundText = user.backgroundInfo
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Your background information has been updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // Save background information to user model
    private func saveBackgroundInfo() {
        guard var updatedUser = userViewModel.currentUser else { return }
        
        // Update background info
        updatedUser.backgroundInfo = backgroundText
        
        // Update user in ViewModel
        userViewModel.updateProfile(updatedUser: updatedUser)
    }
}

struct EditBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        EditBackgroundView()
            .environmentObject(ScoutUserViewModel())
    }
}
