//
//  GuestPropertyListingsTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct GuestPropertyListingsTab: View {
    var body: some View {
        List {
            Section {
                ForEach(Property.samples, id: \.propertyId) { property in
                    NavigationLink {
                        PropertyDetailsView(property: property)
                    } label: {
                        PropertyRowView(property: property)
                    }
                }
            } header: {
                Label(
                    "Guest Mode - View Property Listing",
                    systemImage: "person"
                )
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
