//
//  UserProfile.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import Foundation

/// Represents the profile information stored for an authenticated app user.
struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    let userId: String
    var email: String
    var fullName: String
    var role: AppUserRole
    var phoneNumber: String

    /// Provides the stable identifier required by SwiftUI list and navigation APIs.
    var id: String { userId }

    /// Creates a profile model from the persisted auth and role fields.
    init(
        userId: String,
        email: String,
        fullName: String,
        role: AppUserRole,
        phoneNumber: String
    ) {
        self.userId = userId
        self.email = email
        self.fullName = fullName
        self.role = role
        self.phoneNumber = phoneNumber
    }

    /// Returns the preferred display name, falling back to email when needed.
    var displayName: String {
        let trimmedName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return trimmedName.isEmpty ? email : trimmedName
    }
}
