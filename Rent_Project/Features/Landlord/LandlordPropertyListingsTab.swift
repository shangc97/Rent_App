//
//  LandlordPropertyListingsTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct LandlordPropertyListingsTab: View {
    private let sampleProperties = [
        "Downtown Condo",
        "North York Basement Suite",
        "Mississauga Townhouse"
    ]

    var body: some View {
        List {
            Section("Your Property Listing") {
                ForEach(sampleProperties, id: \.self) { property in
                    NavigationLink {
                        PropertyDetailsView()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(property)
                                .font(.headline)
                            Text("Tap to preview a managed property.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("What comes later") {
                Text(
                    "This tab will grow into landlord property CRUD: add, edit, list, and delist properties."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("My Listings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Landlord Listings Tab") {
    NavigationStack {
        LandlordPropertyListingsTab()
    }
}
