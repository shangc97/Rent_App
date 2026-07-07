//
//  TenantShortlistTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct TenantShortlistTab: View {
    private let sampleShortlist = [
        "Downtown Studio",
        "North York Condo",
        "Waterfront Apartment"
    ]

    var body: some View {
        List {
            Section("My Shortlist") {
                ForEach(sampleShortlist, id: \.self) { property in
                    NavigationLink {
                        PropertyDetailsView()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(property)
                                .font(.headline)
                            Text("Saved by the tenant for later comparison.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("What comes later") {
                Text(
                    "This tab will later show the tenant's saved shortlist and support add or remove actions."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("My Shortlist")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Tenant Shortlist Tab") {
    NavigationStack {
        TenantShortlistTab()
    }
}
