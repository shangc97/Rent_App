//
//  PropertySearchView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct PropertySearchView: View {
    @State private var userInput = ""

    var body: some View {
        List {
            Section("Search Property") {
                TextField(
                    "Search by city, address, or keyword",
                    text: $userInput
                )
                .textInputAutocapitalization(.words)
            }

            Section("Search Results") {
                if filteredProperties.isEmpty {
                    Text("No matching properties.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredProperties, id: \.propertyId) { property in
                        NavigationLink {
                            PropertyDetailsView(property: property)
                        } label: {
                            PropertyRowView(property: property)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filteredProperties: [Property] {
        let searchableProperties = Property.samples.filter { $0.isListed }
        let trimmedKeyword = userInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedKeyword.isEmpty else { return searchableProperties }

        return searchableProperties.filter { property in
            property.title.localizedCaseInsensitiveContains(trimmedKeyword)
                || property.address.city.localizedCaseInsensitiveContains(
                    trimmedKeyword
                )
                || property.address.streetAddress
                    .localizedCaseInsensitiveContains(trimmedKeyword)
                || property.address.fullAddress
                    .localizedCaseInsensitiveContains(trimmedKeyword)
        }
    }
}

#Preview("Shared Property Search") {
    NavigationStack {
        PropertySearchView()
    }
}
