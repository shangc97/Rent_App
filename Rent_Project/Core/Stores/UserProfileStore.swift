//
//  UserProfileStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import Foundation
import Observation

/// Holds the active user profile and exposes profile loading and update actions for the UI.
@MainActor
@Observable
final class UserProfileStore {
    var currentUserProfile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    private let userProfileRepository: UserProfileRepository

    init() {
        self.userProfileRepository = UserProfileRepository()
    }

    init(userProfileRepository: UserProfileRepository) {
        self.userProfileRepository = userProfileRepository
    }

    /// Creates a new user profile document and mirrors it into local state.
    func createUserProfile(_ userProfile: UserProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            try await userProfileRepository.createUserProfile(userProfile)
            currentUserProfile = userProfile
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Loads the user profile for the supplied user id.
    func loadUserProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        currentUserProfile = nil

        do {
            currentUserProfile = try await userProfileRepository.fetchUserProfile(
                userId: userId
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Updates an existing user profile document and local state.
    func updateUserProfile(_ userProfile: UserProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            try await userProfileRepository.updateUserProfile(userProfile)
            currentUserProfile = userProfile
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Clears the currently cached user profile from memory.
    func clearUserProfile() {
        currentUserProfile = nil
        errorMessage = nil
    }
}
