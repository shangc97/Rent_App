//
//  PropertyDetailsInfoView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the core property information shown on the property details page.
struct PropertyDetailsInfoView: View {
    let property: Property

    var body: some View {
        Group {
            Section("Property Snapshot") {
                LabeledContent("Title", value: property.title)
                LabeledContent(
                    "Monthly Rent Fee",
                    value: property.formattedRent
                )
                LabeledContent("Status", value: property.status.displayName)
            }

            Section("Location") {
                LabeledContent("Address", value: property.address.streetAddress)
                LabeledContent("City", value: property.address.city)
                LabeledContent("Province", value: property.address.province)
                LabeledContent(
                    "Postal Code",
                    value: property.address.postalCode
                )
            }

            Section("Layout") {
                LabeledContent(
                    "Bedroom",
                    value: "\(property.layout.bedroomCount)"
                )
                LabeledContent(
                    "Bathroom",
                    value: "\(property.layout.bathroomCount)"
                )
                if property.layout.hasDen {
                    LabeledContent("Den", value: "\(property.layout.denCount)")
                }
            }

            if property.hasParking {
                Section("Features") {
                    LabeledContent(
                        "Parking",
                        value: "\(property.parkingSpaceCount)"
                    )
                }
            }

            LandlordInfoSectionView(landlordId: property.landlordId)

            Section("Description") {
                Text(property.description)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
