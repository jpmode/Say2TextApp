//
//  AuthStateManager.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/9/24.
//

import Foundation
import Combine
import WatchConnectivity



// Define custom notification name
extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}


class AuthStateManager: ObservableObject {
    @Published var isAuthenticated: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Listen for the auth state change notification
        NotificationCenter.default.addObserver(self, selector: #selector(authStateChanged(notification:)), name: .authStateChanged, object: nil)

        // Listen for any changes from the iPhone via WatchConnectivity
        WatchConnectivityManager_Watch.shared.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)
    }

    @objc private func authStateChanged(notification: Notification) {
        if let state = notification.object as? Bool {
            self.isAuthenticated = state
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .authStateChanged, object: nil)
    }
}



