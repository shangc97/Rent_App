//
//  Property.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import Foundation

struct Property {
    var propertyId: UUID
    var landlordId: UUID
    var title: String
    var description: String
    var address: String
    var city: String
    var rentFee: Double
    var bedrooms: Int
    var bathrooms: Int
    var isListed: Bool
}

extension Property {
    static let sample = Property(
        propertyId: UUID(),
        landlordId: UUID(),
        title: "Downtown Condo",
        description: "Bright condo close to transit, groceries, and the waterfront.",
        address: "123 King Street West",
        city: "Toronto",
        rentFee: 2450,
        bedrooms: 2,
        bathrooms: 1,
        isListed: true
    )

    var formattedRent: String {
        rentFee.formatted(.currency(code: "CAD"))
    }

    var shareSummary: String {
        let bedroomText = "\(bedrooms) bedroom" + (bedrooms == 1 ? "" : "s")
        let bathroomText = "\(bathrooms) bathroom" + (bathrooms == 1 ? "" : "s")

        return """
        Check out this property:
        \(title)
        \(address), \(city)
        Rent: \(formattedRent) per month
        Layout: \(bedroomText), \(bathroomText)
        Details: \(description)
        """
    }
}
