//
//  UserProfileStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import Foundation
import Observation

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

    func loadUserProfile(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUserProfile = try await userProfileRepository.fetchUserProfile(
                userId: userId
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

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

    func clearUserProfile() {
        currentUserProfile = nil
        errorMessage = nil
    }
}
