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

    /// Lays out the search field and the independently scrollable search results.
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                searchInputSection
                searchResultsSection
                    .frame(
                        minHeight: max(geometry.size.height * 0.45, 320),
                        maxHeight: .infinity
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .top
            )
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await propertyStore.loadAllPropertiesIfNeeded()
        }
    }

    /// Displays the search title and text field input area.
    private var searchInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Property")
                .font(.headline)

            searchTextField
        }
    }

    /// Displays the framed results area and its scrollable content.
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Results")
                .font(.headline)

            ScrollView {
                LazyVStack(spacing: 12) { resultsContent }
                .padding(16)
            }
            .scrollIndicators(.visible)
            .background(resultsBackground)
            .overlay(resultsBorder)
        }
    }

    /// Renders the shared search input field styling.
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

    /// Chooses between the two empty states and the filtered result list.
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

    /// Returns the currently entered search keyword without outer whitespace.
    private var trimmedKeyword: String {
        userInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Indicates whether the user has entered any searchable keyword.
    private var hasSearchKeyword: Bool {
        !trimmedKeyword.isEmpty
    }

    /// Returns only properties that are currently listed and eligible for search.
    private var searchableProperties: [Property] {
        propertyStore.properties.filter { $0.isListed }
    }

    /// Filters listed properties against the current keyword.
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

    /// Provides the shared background used by the search input field.
    private var searchFieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
    }

    /// Provides the shared border used by the search input field.
    private var searchFieldBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }

    /// Provides the background card used behind the results scroll view.
    private var resultsBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
    }

    /// Provides the border used around the results scroll view container.
    private var resultsBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }

    /// Renders a consistent empty state layout inside the results container.
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

    /// Builds the navigation card for a single filtered property result.
    private func propertyResultLink(for property: Property) -> some View {
        NavigationLink {
            PropertyDetailsView(property: property)
        } label: {
            PropertyRowView(property: property)
                .padding(14)
                .background(resultCardBackground)
                .overlay(resultCardBorder)
        }
        .buttonStyle(.plain)
    }

    /// Provides the card background used for each search result row.
    private var resultCardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground))
    }

    /// Provides the border used for each search result row.
    private var resultCardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }
}
