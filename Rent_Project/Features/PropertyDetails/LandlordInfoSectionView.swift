//
//  LandlordInfoSectionView.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-09.
//

import SwiftUI

/// Loads and displays the landlord contact information associated with the
/// current property listing.
struct LandlordInfoSectionView: View {
    let landlordId: String

    @State private var landlordProfile: UserProfile?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let userProfileRepository = UserProfileRepository()

    var body: some View {
        Section("Landlord Info") {
            if isLoading {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Loading landlord information...")
                        .foregroundStyle(.secondary)
                }
            } else if let landlordProfile {
                LabeledContent("Name", value: landlordProfile.displayName)
                LabeledContent("Email", value: landlordProfile.email)
                LabeledContent("Phone", value: landlordProfile.phoneNumber)
            } else {
                Text(landlordInfoFallbackMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: landlordId) {
            await loadLandlordProfile()
        }
    }

    private var landlordInfoFallbackMessage: String {
        errorMessage ?? "Landlord information is unavailable right now."
    }

    @MainActor
    private func loadLandlordProfile() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            landlordProfile = try await userProfileRepository.fetchUserProfile(
                userId: landlordId
            )
        } catch {
            landlordProfile = nil
            errorMessage = error.localizedDescription
        }
    }
}
