//
//  UserProfile.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import Foundation

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

extension UserProfile {
    static let sampleTenant = UserProfile(
        userId: "demo-tenant",
        email: "tenant@example.com",
        fullName: "Taylor Tenant",
        role: .tenant,
        phoneNumber: "647-555-0101"
    )

    static let sampleLandlord = UserProfile(
        userId: "demo-landlord",
        email: "landlord@example.com",
        fullName: "Logan Landlord",
        role: .landlord,
        phoneNumber: "416-555-0123"
    )

    static let samples = [
        sampleTenant,
        sampleLandlord,
    ]
}
