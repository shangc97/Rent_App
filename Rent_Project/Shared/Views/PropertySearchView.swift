//
//  PropertySearchView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct PropertySearchView: View {
    let navigationTitle: String
    let helperText: String

    @State private var keyword = ""

    var body: some View {
        List {
            Section("Search Property") {
                TextField("Search by city, address, or keyword", text: $keyword)
                    .textInputAutocapitalization(.never)

                Text(helperText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Sample Search Result") {
                NavigationLink("Open Matching Property") {
                    PropertyDetailsView()
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Shared Property Search") {
    NavigationStack {
        PropertySearchView(
            navigationTitle: "Search",
            helperText: "This shared search view can be reused by guest, tenant, and landlord flows."
        )
    }
}
