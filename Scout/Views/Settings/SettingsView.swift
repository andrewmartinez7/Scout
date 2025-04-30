// SettingsView.swift
import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: ScoutUserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            ZStack {
                Rectangle()
                    .fill(ScoutColors.primaryBlue)
                    .frame(height: 90)
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                .padding(.top, 40) // For safe area
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Account settings section
                    settingsSection(
                        title: "Account",
                        items: [
                            SettingsItem(
                                icon: "person.fill",
                                title: "Edit Profile",
                                destination: AnyView(ProfileSelfView())
                            ),
                            SettingsItem(
                                icon: "envelope.fill",
                                title: "Change Email",
                                destination: AnyView(ChangeEmailView())
                            ),
                            SettingsItem(
                                icon: "lock.fill",
                                title: "Change Password",
                                destination: AnyView(ChangePasswordView())
                            )
                        ]
                    )
                    
                    // Content settings section
                    settingsSection(
                        title: "Content",
                        items: [
                            SettingsItem(
                                icon: "bell.fill",
                                title: "Notifications",
                                destination: AnyView(Text("Notifications Settings"))
                            ),
                            SettingsItem(
                                icon: "eye.fill",
                                title: "Privacy",
                                destination: AnyView(Text("Privacy Settings"))
                            )
                        ]
                    )
                    
                    // App settings section
                    settingsSection(
                        title: "App",
                        items: [
                            SettingsItem(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                destination: AnyView(Text("Help & Support"))
                            ),
                            SettingsItem(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                destination: AnyView(Text("Terms of Service"))
                            ),
                            SettingsItem(
                                icon: "hand.raised.fill",
                                title: "Privacy Policy",
                                destination: AnyView(Text("Privacy Policy"))
                            )
                        ]
                    )
                    
                    // Logout button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            
                            Text("Log Out")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    }
                    .padding(.horizontal)
                    
                    // App version
                    Text("Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    userViewModel.logout()
                },
                secondaryButton: .cancel()
            )
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: {
                        navigationCoordinator.resetToSearchRoot()
                    }) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                            Text("Search")
                                .font(.caption)
                        }
                        .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        navigationCoordinator.resetToProfileRoot()
                    }) {
                        VStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                            Text("Profile")
                                .font(.caption)
                        }
                        .foregroundColor(Color.gray)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    // Helper for creating settings sections
    private func settingsSection(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                ForEach(items, id: \.title) { item in
                    NavigationLink(destination: item.destination) {
                        HStack {
                            Image(systemName: item.icon)
                                .font(.system(size: 16))
                                .foregroundColor(ScoutColors.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            Text(item.title)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    
                    if items.last?.title != item.title {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            .padding(.horizontal)
        }
    }
}

// Helper struct for settings items
struct SettingsItem {
    let icon: String
    let title: String
    let destination: AnyView
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ScoutUserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
