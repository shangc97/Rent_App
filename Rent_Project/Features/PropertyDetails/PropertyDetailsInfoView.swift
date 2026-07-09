//
//  PropertyDetailsInfoView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the core property information shown on the property details page.
struct PropertyDetailsInfoView: View {
    let property: Property

    @State private var landlordProfile: UserProfile?
    @State private var isLoadingLandlordInfo = false
    @State private var landlordInfoErrorMessage: String?

    private let userProfileRepository = UserProfileRepository()

    var body: some View {
        Group {
            Section("Property Snapshot") {
                LabeledContent("Title", value: property.title)
                LabeledContent(
                    "Monthly Rent Fee",
                    value: property.formattedRent
                )
                LabeledContent("Status", value: property.status.displayName)
            }

            Section("Location") {
                LabeledContent("Address", value: property.address.streetAddress)
                LabeledContent("City", value: property.address.city)
                LabeledContent("Province", value: property.address.province)
                LabeledContent(
                    "Postal Code",
                    value: property.address.postalCode
                )
            }

            Section("Layout") {
                LabeledContent(
                    "Bedroom",
                    value: "\(property.layout.bedroomCount)"
                )
                LabeledContent(
                    "Bathroom",
                    value: "\(property.layout.bathroomCount)"
                )
                if property.layout.hasDen {
                    LabeledContent("Den", value: "\(property.layout.denCount)")
                }
            }

            if property.hasParking {
                Section("Features") {
                    LabeledContent(
                        "Parking",
                        value: "\(property.parkingSpaceCount)"
                    )
                }
            }

            landlordInfoSection

            Section("Description") {
                Text(property.description)
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: property.landlordId) {
            await loadLandlordProfile()
        }
    }

    /// Loads and displays the landlord contact information associated with the
    /// current property listing.
    private var landlordInfoSection: some View {
        Section("Landlord Info") {
            if isLoadingLandlordInfo {
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
    }

    /// Returns the fallback message shown when landlord info cannot be loaded.
    private var landlordInfoFallbackMessage: String {
        landlordInfoErrorMessage ?? "Landlord information is unavailable right now."
    }

    /// Fetches the landlord profile used by the details page.
    @MainActor
    private func loadLandlordProfile() async {
        isLoadingLandlordInfo = true
        landlordInfoErrorMessage = nil

        defer {
            isLoadingLandlordInfo = false
        }

        do {
            landlordProfile = try await userProfileRepository.fetchUserProfile(
                userId: property.landlordId
            )
        } catch {
            landlordProfile = nil
            landlordInfoErrorMessage = error.localizedDescription
        }
    }
}
