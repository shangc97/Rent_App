//
//  Property.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import Foundation

struct Property: Identifiable, Codable, Hashable, Sendable {
    let propertyId: String
    var landlordId: String
    var title: String
    var description: String
    var address: PropertyAddress
    var monthlyRent: Int
    var layout: PropertyLayout
    var parkingSpaceCount: Int
    var status: PropertyStatus
    var imageURL: String

    var id: String { propertyId }

    var isListed: Bool {
        status == .listed
    }

    var formattedRent: String {
        monthlyRent.formatted(.currency(code: "CAD"))
    }

    var hasParking: Bool {
        parkingSpaceCount > 0
    }

    var shareSummary: String {
        return """
            Check out this property:
            \(title)
            \(address.fullAddress)
            Rent: \(formattedRent) per month
            Layout: \(layout.summary) • \(parkingSpaceCount) parking
            Status: \(status.displayName)
            Details: \(description)
            """
    }
}

struct PropertyAddress: Codable, Hashable, Sendable {
    var streetAddress: String
    var city: String
    var province: String
    var postalCode: String

    var fullAddress: String {
        "\(streetAddress), \(city), \(province) \(postalCode)"
    }
}

struct PropertyLayout: Codable, Hashable, Sendable {
    var bedroomCount: Int
    var denCount: Int
    var bathroomCount: Int

    var hasDen: Bool {
        denCount > 0
    }

    var bedroomText: String {
        "\(bedroomCount) bedroom" + (bedroomCount == 1 ? "" : "s")
    }

    var bathroomText: String {
        "\(bathroomCount) bathroom" + (bathroomCount == 1 ? "" : "s")
    }

    var denText: String? {
        guard hasDen else { return nil }
        return "\(denCount) den" + (denCount == 1 ? "" : "s")
    }

    var summary: String {
        [
            bedroomText,
            bathroomText,
            denText,
        ]
        .compactMap { $0 }
        .joined(separator: " • ")
    }
}

enum PropertyStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case listed
    case unlisted
    case rented

    var displayName: String {
        switch self {
        case .listed:
            "Available"
        case .unlisted:
            "Unlisted"
        case .rented:
            "Rented"
        }
    }
}
