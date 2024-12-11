//
//  SignInView.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/7/24.


import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var userIdentifier: String? = nil
    @State private var errorMessage: String? = nil
    @State private var isAuthenticated: Bool = false

    var body: some View {
        VStack {
            if isAuthenticated {
                Text("Welcome back!")
                    .font(.title)
                    .padding()
                Button("Sign Out") {
                    signOut()
                }
                .foregroundColor(.red)
                .padding()
            } else {
                Text("Welcome to SAY2TEXT")
                        .font(.largeTitle) // Larger font size than .title
                        .fontWeight(.bold) // Make it bold for emphasis
                        .padding()

                    Text("Your voice, your notes, synced effortlessly.")
                        .font(.subheadline) // Subtitle style
                        .foregroundColor(.gray) // Optional: Gray color for the subtitle
                        .padding(.top, -10)

                SignInWithAppleButton(.signIn, onRequest: configureAppleRequest, onCompletion: handleAppleCompletion)
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            checkForExistingAccount()
        }
    }

    // MARK: - Configure Apple Request
    private func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // MARK: - Handle Apple Sign-In Completion
    private func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user

                // Save the user ID to the Keychain
                do {
                    try KeychainHelper.shared.save(userIdentifier, for: "userIdentifierKey")
                    self.userIdentifier = userIdentifier
                    self.isAuthenticated = true
                    self.errorMessage = nil
                    
                    // Send the auth state to Watch
                    WatchConnectivityManager_iPhone.shared.sendAuthStateToWatch(isAuthenticated: true)
                } catch {
                    self.errorMessage = "Failed to save user ID to Keychain: \(error)"
                }
            }
        case .failure(let error):
            self.errorMessage = "Sign-in failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Check for Existing Account
    private func checkForExistingAccount() {
        do {
            userIdentifier = try KeychainHelper.shared.retrieve(for: "userIdentifierKey")
            isAuthenticated = userIdentifier != nil
        } catch {
            isAuthenticated = false
            errorMessage = "No saved user found. Please sign in."
        }
    }

    // MARK: - Sign Out
    private func signOut() {
        // Clear in-memory state without deleting from Keychain
        userIdentifier = nil
        isAuthenticated = false
        
        // Send sign-out state to the Watch
        WatchConnectivityManager_iPhone.shared.sendAuthStateToWatch(isAuthenticated: false)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
