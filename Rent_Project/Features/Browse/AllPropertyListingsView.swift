//
//  AllPropertyListingsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the full set of currently available property listings and routes
/// each result into its detail screen.
struct AllPropertyListingsView: View {
    @Environment(PropertyStore.self) private var propertyStore

    @State private var selectedStatus: PropertyStatus = .listed

    /// Lays out the status filter and the independently scrollable listings area.
    var body: some View {
        FixedTopScrollableResultsLayout(
            resultsTitle: "\(selectedStatus.rawValue.capitalized) Properties",
            scrollIdentity: listingSectionIdentity
        ) {
            listingFilterSection
        } resultsContent: {
            listingResultsContent
        }
        .navigationTitle("Property Listings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await propertyStore.loadAllPropertiesIfNeeded()
        }
    }

    /// Keeps the segmented status picker fixed at the top of the page.
    private var listingFilterSection: some View {
        PropertyStatusFilterPicker(selection: $selectedStatus)
    }

    /// Provides a stable identity for scroll content refreshes when the selected filter changes.
    private var listingSectionIdentity: String {
        filteredProperties.map(\.propertyId).joined(separator: "|")
    }

    /// Returns only the properties that match the currently selected status.
    private var filteredProperties: [Property] {
        properties.filter { $0.status == selectedStatus }
    }

    /// Returns the current property list from the shared store.
    private var properties: [Property] {
        propertyStore.properties
    }

    /// Chooses between the empty state and the filtered property results.
    @ViewBuilder
    private var listingResultsContent: some View {
        if filteredProperties.isEmpty {
            EmptyStateView(
                title: emptyStateTitle,
                message: emptyStateMessage,
                systemImage: "building.2"
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            ForEach(filteredProperties) { property in
                propertyLink(for: property)
            }
        }
    }

    /// Builds the navigation row for a single property listing.
    private func propertyLink(for property: Property) -> some View {
        NavigationLink {
            PropertyDetailsView(property: property)
        } label: {
            ResultsCardView {
                PropertyRowView(property: property)
            }
        }
        .buttonStyle(.plain)
    }

    /// Returns the empty-state title for the active property-status filter.
    private var emptyStateTitle: String {
        "No \(selectedStatus.rawValue.capitalized) Properties"
    }

    /// Returns the empty-state message for the active property-status filter.
    private var emptyStateMessage: String {
        switch selectedStatus {
        case .listed:
            return
                "Properties that are currently available for rent will appear here."
        case .unlisted:
            return "Properties that are currently unlisted will appear here."
        case .rented:
            return "Properties that are currently rented will appear here."
        }
    }

}
