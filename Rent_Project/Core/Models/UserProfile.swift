//
//  UserProfile.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import Foundation

/// Represents the profile information stored for an authenticated app user.
struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    let userId: String
    var email: String
    var fullName: String
    var role: AppUserRole
    var phoneNumber: String

    var id: String { userId }

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

    var displayName: String {
        let trimmedName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return trimmedName.isEmpty ? email : trimmedName
    }
}
