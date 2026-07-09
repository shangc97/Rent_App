//
//  RentalRequest.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import Foundation

/// Represents a tenant's rental request for a specific property.
struct RentalRequest: Identifiable, Codable, Hashable, Sendable {
    let requestId: String
    let propertyId: String
    let tenantId: String
    let landlordId: String
    var status: RentalRequestStatus
    var message: String

    /// Provides the stable identifier required by SwiftUI list and navigation APIs.
    var id: String { requestId }
}

/// Defines the review lifecycle state of a rental request.
enum RentalRequestStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case submitted
    case withdrawn
    case approved
    case rejected

    /// Returns the user-facing label shown for the current request status.
    var displayName: String {
        switch self {
        case .submitted:
            "Submitted"
        case .withdrawn:
            "Withdrawn"
        case .approved:
            "Approved"
        case .rejected:
            "Denied"
        }
    }
}
