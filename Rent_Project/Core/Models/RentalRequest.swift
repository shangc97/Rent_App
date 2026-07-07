//
//  RentalRequest.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import Foundation

struct RentalRequest: Identifiable, Codable, Hashable, Sendable {
    let requestId: String
    let propertyId: String
    let tenantId: String
    let landlordId: String
    var status: RentalRequestStatus
    var message: String

    var id: String { requestId }
}

enum RentalRequestStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case submitted
    case withdrawn
    case approved
    case rejected

    var displayName: String {
        switch self {
        case .submitted:
            "Submitted"
        case .withdrawn:
            "Withdrawn"
        case .approved:
            "Approved"
        case .rejected:
            "Rejected"
        }
    }
}

extension RentalRequest {
    static let sampleSubmitted = RentalRequest(
        requestId: "request-downtown-condo-taylor",
        propertyId: Property.sampleCondo.propertyId,
        tenantId: UserProfile.sampleTenant.userId,
        landlordId: Property.sampleCondo.landlordId,
        status: .submitted,
        message: "I am interested in booking a viewing this week and can move in next month."
    )

    static let sampleApproved = RentalRequest(
        requestId: "request-lakeshore-townhouse-taylor",
        propertyId: Property.sampleTownhouse.propertyId,
        tenantId: UserProfile.sampleTenant.userId,
        landlordId: Property.sampleTownhouse.landlordId,
        status: .approved,
        message: "I have stable income and would love to schedule the next step."
    )

    static let samples = [
        sampleSubmitted,
        sampleApproved,
    ]
}
