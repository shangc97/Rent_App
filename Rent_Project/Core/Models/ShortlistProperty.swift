//
//  ShortlistProperty.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import Foundation

struct ShortlistProperty: Identifiable, Codable, Hashable, Sendable {
    let shortlistPropertyId: String
    let tenantId: String
    let propertyId: String

    var id: String { shortlistPropertyId }
}

extension ShortlistProperty {
    static let sampleCondo = ShortlistProperty(
        shortlistPropertyId: "shortlist-downtown-condo-taylor",
        tenantId: UserProfile.sampleTenant.userId,
        propertyId: Property.sampleCondo.propertyId
    )

    static let sampleTownhouse = ShortlistProperty(
        shortlistPropertyId: "shortlist-lakeshore-townhouse-taylor",
        tenantId: UserProfile.sampleTenant.userId,
        propertyId: Property.sampleTownhouse.propertyId
    )

    static let samples = [
        sampleCondo,
        sampleTownhouse,
    ]
}
