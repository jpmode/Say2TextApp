//
//  ContentView.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/7/24.
//
import SwiftUI

struct PhoneContentView: View {
    @State private var isAuthenticated = false // Track sign-in state locally

    var body: some View {
        VStack {
            if isAuthenticated {
                // Show the main content view after sign-in
                MainView(isAuthenticated: $isAuthenticated)
            } else {
                // Show the sign-in screen
                SignInView()
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
    }

    // Check Keychain for existing user authentication status
    private func checkAuthenticationStatus() {
        do {
            let userIdentifier = try KeychainHelper.shared.retrieve(for: "userIdentifierKey")
            isAuthenticated = (userIdentifier != nil) // If user ID exists, they are authenticated
        } catch {
            isAuthenticated = false // Default to unauthenticated
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneContentView()
    }
}

