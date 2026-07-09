//
//  AuthRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-05.
//

import FirebaseAuth
import Foundation

/// Wraps Firebase Authentication account and session operations for the app.
final class AuthRepository {
    private var auth: Auth {
        Auth.auth()
    }

    /// Returns the current authenticated user's id when a Firebase session exists.
    func currentUserId() -> String? {
        auth.currentUser?.uid
    }

    /// Creates a Firebase account and returns the new user's id.
    func createAccount(email: String, password: String) async throws -> String {
        let authResult = try await auth.createUser(
            withEmail: email,
            password: password
        )

        return authResult.user.uid
    }

    /// Signs in an existing Firebase account and returns the authenticated user's id.
    func signIn(email: String, password: String) async throws -> String {
        let authResult = try await auth.signIn(
            withEmail: email,
            password: password
        )

        return authResult.user.uid
    }

    /// Signs the current user out of Firebase Authentication.
    func signOut() throws {
        try auth.signOut()
    }
}
