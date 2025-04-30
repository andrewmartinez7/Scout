//
//  EditTeamsView.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
//

import SwiftUI

struct EditTeamsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    
    @State private var teams: [String] = []
    @State private var newTeam: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScoutHeader(
                title: "Edit Teams",
                hasBackButton: true,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Add new team
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Team")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            TextField("Enter team name", text: $newTeam)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Button(action: addTeam) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(ScoutColors.primaryBlue)
                            }
                            .disabled(newTeam.isEmpty)
                        }
                        
                        Text("Add teams you've played for or are currently with")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Teams list
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Teams")
                            .font(.system(size: 16, weight: .semibold))
                        
                        if teams.isEmpty {
                            Text("You haven't added any teams yet")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(teams.indices, id: \.self) { index in
                                HStack {
                                    Text(teams[index])
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        removeTeam(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save button
                    Button(action: saveTeams) {
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
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: loadTeams)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Teams"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Your teams have been updated successfully." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    // Load teams from user model
    private func loadTeams() {
        if let user = userViewModel.currentUser {
            teams = user.teams
        }
    }
    
    // Add a new team
    private func addTeam() {
        guard !newTeam.isEmpty else { return }
        
        // Check if team already exists
        if !teams.contains(newTeam) {
            teams.append(newTeam)
        }
        
        // Clear input field
        newTeam = ""
    }
    
    // Remove a team
    private func removeTeam(at index: Int) {
        teams.remove(at: index)
    }
    
    // Save teams to user model
    private func saveTeams() {
        // Show loading indicator
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if var user = self.userViewModel.currentUser {
                // Update user model
                user.teams = self.teams
                self.userViewModel.updateProfile(updatedUser: user)
                
                // Show success message
                self.alertMessage = "Your teams have been updated successfully."
                self.showAlert = true
            } else {
                // Show error message
                self.alertMessage = "Failed to save teams. Please try again."
                self.showAlert = true
            }
            
            // Hide loading indicator
            self.isLoading = false
        }
    }
}

struct EditTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        EditTeamsView()
            .environmentObject(ScoutUserViewModel())
    }
}
