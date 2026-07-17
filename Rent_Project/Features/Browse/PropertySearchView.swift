//
//  PropertySearchView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Provides a searchable property browser that filters listed homes by user
/// keyword input.
struct PropertySearchView: View {
    @Environment(PropertyStore.self) private var propertyStore
    @State private var userInput = ""

    var body: some View {
        FixedTopScrollableResultsLayout(
            resultsTitle: "Search Results",
            scrollIdentity: searchResultsIdentity
        ) {
            searchInputSection
        } resultsContent: {
            resultsContent
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await propertyStore.loadAllPropertiesIfNeeded()
        }
    }

    private var searchInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Property")
                .font(.headline)

            searchTextField
        }
    }

    private var searchTextField: some View {
        TextField(
            "Search by city, address, or keyword",
            text: $userInput
        )
        .textInputAutocapitalization(.words)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(searchFieldBackground)
        .overlay(searchFieldBorder)
    }

    @ViewBuilder
    private var resultsContent: some View {
        if !hasSearchKeyword {
            emptyResultsState(
                title: "Start Searching",
                message: "Enter a city, address, or keyword to see matching property listings.",
                systemImage: "magnifyingglass"
            )
        } else if filteredProperties.isEmpty {
            emptyResultsState(
                title: "No Matching Properties",
                message: "Try a different city, address, or keyword.",
                systemImage: "building.2"
            )
        } else {
            ForEach(filteredProperties, id: \.propertyId) { property in
                propertyResultLink(for: property)
            }
        }
    }

    private var trimmedKeyword: String {
        userInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasSearchKeyword: Bool {
        !trimmedKeyword.isEmpty
    }

    private var searchableProperties: [Property] {
        propertyStore.properties.filter { $0.isListed }
    }

    private var filteredProperties: [Property] {
        guard hasSearchKeyword else { return [] }

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

    private var searchResultsIdentity: String {
        filteredProperties.map(\.propertyId).joined(separator: "|")
    }

    private var searchFieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
    }

    private var searchFieldBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }

    private func emptyResultsState(
        title: String,
        message: String,
        systemImage: String
    ) -> some View {
        EmptyStateView(
            title: title,
            message: message,
            systemImage: systemImage
        )
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func propertyResultLink(for property: Property) -> some View {
        NavigationLink {
            PropertyDetailsView(property: property)
        } label: {
            ResultsCardView {
                PropertyRowView(property: property)
            }
        }
        .buttonStyle(.plain)
    }
}
