//
//  AuthStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-05.
//

import Foundation
import Observation

/// Tracks authentication UI state and delegates account actions to `AuthRepository`.
@MainActor
@Observable
final class AuthStore {
    var currentUserId: String?
    var isLoading = false
    var errorMessage: String?

    private let authRepository: AuthRepository

    init() {
        self.authRepository = AuthRepository()
    }

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Restores the current Firebase session into observable app state.
    func restoreSession() {
        errorMessage = nil
        currentUserId = authRepository.currentUserId()
    }

    /// Creates an account and stores the authenticated user's id on success.
    func createAccount(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUserId = try await authRepository.createAccount(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Signs in an existing user and stores the authenticated user's id on success.
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUserId = try await authRepository.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Clears the Firebase session and local auth state.
    func signOut() {
        errorMessage = nil

        do {
            try authRepository.signOut()
            currentUserId = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
