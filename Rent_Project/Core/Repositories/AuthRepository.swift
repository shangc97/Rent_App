//
//  AuthRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import FirebaseAuth
import Foundation

final class AuthRepository {
    private let auth = Auth.auth()

    func currentUserId() -> String? {
        auth.currentUser?.uid
    }

    func createAccount(email: String, password: String) async throws -> String {
        let authResult = try await auth.createUser(
            withEmail: email,
            password: password
        )

        return authResult.user.uid
    }

    func signIn(email: String, password: String) async throws -> String {
        let authResult = try await auth.signIn(
            withEmail: email,
            password: password
        )

        return authResult.user.uid
    }

    func signOut() throws {
        try auth.signOut()
    }
}
