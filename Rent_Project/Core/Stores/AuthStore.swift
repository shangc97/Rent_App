//
//  AuthStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import Foundation
import Observation

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

    func restoreSession() {
        errorMessage = nil
        currentUserId = authRepository.currentUserId()
    }

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
