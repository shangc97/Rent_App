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
