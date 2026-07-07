//
//  PropertyDetailsContentView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct PropertyDetailsContentView: View {
    let property: Property

    var body: some View {
        Group {
            Section("Property Snapshot") {
                LabeledContent("Title", value: property.title)
                LabeledContent("Rent", value: property.formattedRent)
                LabeledContent("Status", value: property.status.displayName)
            }

            Section("Location") {
                LabeledContent("Address", value: property.address.streetAddress)
                LabeledContent("City", value: property.address.city)
                LabeledContent("Province", value: property.address.province)
                LabeledContent("Postal Code", value: property.address.postalCode)
            }

            Section("Layout") {
                LabeledContent("Bedrooms", value: "\(property.layout.bedroomCount)")
                LabeledContent("Bathrooms", value: "\(property.layout.bathroomCount)")
                if let denText = property.layout.denText {
                    LabeledContent("Den", value: denText)
                }
            }

            if property.hasParking {
                Section("Features") {
                    LabeledContent("Parking", value: parkingText(for: property))
                }
            }

            Section("Description") {
                Text(property.description)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func parkingText(for property: Property) -> String {
        "\(property.parkingSpaceCount) parking space"
            + (property.parkingSpaceCount == 1 ? "" : "s")
    }
}

//#Preview("Property Details Content") {
//    List {
//        PropertyDetailsContentView(property: .sample)
//    }
//}
