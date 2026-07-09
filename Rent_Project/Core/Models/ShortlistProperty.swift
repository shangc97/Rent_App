//
//  ShortlistProperty.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import Foundation

/// Represents a tenant's saved shortlist entry for a property.
struct ShortlistProperty: Identifiable, Codable, Hashable, Sendable {
    let shortlistPropertyId: String
    let tenantId: String
    let propertyId: String

    /// Provides the stable identifier required by SwiftUI list and navigation APIs.
    var id: String { shortlistPropertyId }
}
