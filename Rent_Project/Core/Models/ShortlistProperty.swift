//
//  ShortlistProperty.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import Foundation

/// Represents a tenant's saved shortlist entry for a property.
struct ShortlistProperty: Identifiable, Codable, Hashable, Sendable {
    let shortlistPropertyId: String
    let tenantId: String
    let propertyId: String

    var id: String { shortlistPropertyId }
}
