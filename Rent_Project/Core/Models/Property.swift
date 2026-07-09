//
//  Property.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import Foundation

/// Represents a rental property listing stored and displayed throughout the app.
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

    /// Provides the stable identifier required by SwiftUI list and navigation APIs.
    var id: String { propertyId }

    /// Indicates whether the property is currently available for public browsing.
    var isListed: Bool {
        status == .listed
    }

    /// Formats the monthly rent using Canadian currency styling.
    var formattedRent: String {
        monthlyRent.formatted(.currency(code: "CAD"))
    }

    /// Indicates whether the property includes at least one parking space.
    var hasParking: Bool {
        parkingSpaceCount > 0
    }

    /// Builds the text payload used when sharing a property summary externally.
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

/// Stores the postal address fields associated with a property listing.
struct PropertyAddress: Codable, Hashable, Sendable {
    var streetAddress: String
    var city: String
    var province: String
    var postalCode: String

    /// Joins the stored address fields into a single display-ready address string.
    var fullAddress: String {
        "\(streetAddress), \(city), \(province) \(postalCode)"
    }
}

/// Describes the bedroom, den, and bathroom counts for a property.
struct PropertyLayout: Codable, Hashable, Sendable {
    var bedroomCount: Int
    var denCount: Int
    var bathroomCount: Int

    /// Indicates whether the layout includes one or more dens.
    var hasDen: Bool {
        denCount > 0
    }

    /// Returns the localized bedroom count text for property summaries.
    var bedroomText: String {
        "\(bedroomCount) bedroom" + (bedroomCount == 1 ? "" : "s")
    }

    /// Returns the localized bathroom count text for property summaries.
    var bathroomText: String {
        "\(bathroomCount) bathroom" + (bathroomCount == 1 ? "" : "s")
    }

    /// Returns the den count text when the layout includes a den.
    var denText: String? {
        guard hasDen else { return nil }
        return "\(denCount) den" + (denCount == 1 ? "" : "s")
    }

    /// Builds the combined layout summary used by browse rows and sharing text.
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

/// Defines the publishing state of a property listing.
enum PropertyStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case listed
    case unlisted
    case rented

    /// Returns the user-facing label shown for the current property status.
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
