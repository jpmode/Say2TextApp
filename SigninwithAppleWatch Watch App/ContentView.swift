//
//  ContentView.swift
//  SigninwithAppleWatch Watch App
//
//  Created by Modeline Jean Pierre on 12/7/24.
//
import SwiftUI
import AuthenticationServices
import WatchConnectivity

struct ContentView: View {
    @StateObject private var authStateManager = AuthStateManager()
    @State private var notes: [Note] = []
    @ObservedObject private var connectivityManager = WatchConnectivityManager_Watch.shared

    var body: some View {
        VStack {
            if authStateManager.isAuthenticated {
                Text("Welcome back!")
                    .font(.title)
                    .padding()
                
                // Display notes from Core Data
                List(notes, id: \.id) { note in
                    VStack(alignment: .leading) {
                        Text(note.content ?? "No content")
                            .font(.body)
                        Text("Created at: \(note.createdAt ?? Date(), formatter: dateFormatter)")
                            .font(.footnote)
                    }
                }
                
                Button("Sign Out") {
                    signOut()
                }
                .foregroundColor(.red)
                .padding()
            } else {
                Text("Please Sign In")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                SignInWithAppleButton(.signIn, onRequest: configureAppleRequest, onCompletion: handleAppleCompletion)
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .padding()
            }
        }
        .onAppear {
            fetchNotes()
        }
        .onReceive(NotificationCenter.default.publisher(for: .authStateChanged)) { _ in
            fetchNotes()
        }
    }

    private func fetchNotes() {
        // Fetch notes from Core Data (or your NoteManager logic)
        notes = NoteManager.shared.fetchNotes()
    }

    // MARK: - Configure Apple Sign-In Request
    private func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // MARK: - Handle Apple Sign-In Completion
    private func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                _ = appleIDCredential.user
                
                // Save the user identifier or handle accordingly
                authStateManager.isAuthenticated = true
                
                // Send the auth state to iPhone via WatchConnectivity
                WatchConnectivityManager_Watch.shared.sendAuthStateToPhone(isAuthenticated: true)
            }
        case .failure(let error):
            print("Sign-In failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Sign-Out Logic
    private func signOut() {
        authStateManager.isAuthenticated = false
        WatchConnectivityManager_Watch.shared.sendAuthStateToPhone(isAuthenticated: false)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
