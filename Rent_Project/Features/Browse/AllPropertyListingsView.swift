//
//  AllPropertyListingsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct AllPropertyListingsView: View {
    let properties: [Property]

    var body: some View {
        List {
            if properties.isEmpty {
                EmptyStateView(
                    title: "No Property Listings",
                    message: "All available property listings will appear here.",
                    systemImage: "building.2"
                )
            } else {
                Section("All Property Listings") {
                    ForEach(properties) { property in
                        NavigationLink {
                            PropertyDetailsView(property: property)
                        } label: {
                            PropertyRowView(property: property)
                        }
                    }
                }
            }
        }
        .navigationTitle("Property Listings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("All Property Listings View") {
    NavigationStack {
        AllPropertyListingsView(properties: Property.samples)
    }
}
