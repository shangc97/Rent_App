//
//  GuestPropertyListingsTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct GuestPropertyListingsTab: View {
    private let sampleListings = [
        "Downtown Condo",
        "Basement Suite",
        "Family Townhouse"
    ]

    var body: some View {
        List {
            Section("Guest Access") {
                Label("Property browsing is available", systemImage: "person")
                Text(
                    "Guests can view listings and open property details, but they cannot shortlist or send rental requests."
                )
                .foregroundStyle(.secondary)
            }

            Section("View Property Listing") {
                ForEach(sampleListings, id: \.self) { listing in
                    NavigationLink {
                        PropertyDetailsView()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing)
                                .font(.headline)
                            Text("Tap to preview the property details flow.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Property Listings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Guest Listings Tab") {
    NavigationStack {
        GuestPropertyListingsTab()
    }
}
