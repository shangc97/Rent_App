//
//  PropertyDetailsContentView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct PropertyDetailsContentView: View {
    let property: Property
    let statusText: String

    var body: some View {
        Group {
            Section("Property Snapshot") {
                LabeledContent("Title", value: property.title)
                LabeledContent("Rent", value: property.formattedRent)
                LabeledContent("Status", value: statusText)
            }

            Section("Location") {
                LabeledContent("Address", value: property.address)
                LabeledContent("City", value: property.city)
            }

            Section("Layout") {
                LabeledContent("Bedrooms", value: "\(property.bedrooms)")
                LabeledContent("Bathrooms", value: "\(property.bathrooms)")
            }

            Section("Description") {
                Text(property.description)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Property Details Content") {
    List {
        PropertyDetailsContentView(
            property: .sample,
            statusText: "Available"
        )
    }
}
