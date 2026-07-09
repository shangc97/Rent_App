//
//  LandlordMyListingsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Shows the signed-in landlord's properties grouped by listing status.
struct LandlordMyListingsView: View {
    @Environment(PropertyStore.self) private var propertyStore

    let landlordId: String

    @State private var selectedStatus: PropertyStatus = .listed

    /// Displays the landlord's filtered listing set inside the shared listings layout.
    var body: some View {
        FixedTopScrollableResultsLayout(
            resultsTitle: sectionHeading,
            scrollIdentity: listingSectionIdentity
        ) {
            filterSection
        } resultsContent: {
            listingResultsContent
        }
        .navigationTitle("My Listings")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: landlordId) {
            await propertyStore.loadAllPropertiesIfNeeded()
        }
    }

    /// Renders the segmented property-status picker shown above the listing results.
    private var filterSection: some View {
        PropertyStatusFilterPicker(
            selection: $selectedStatus,
            title: "Status"
        )
    }

    /// Chooses between the empty state and the filtered property results.
    @ViewBuilder
    private var listingResultsContent: some View {
        if filteredLandlordProperties.isEmpty {
            EmptyStateView(
                title: emptyStateTitle,
                message: emptyStateMessage,
                systemImage: "building.2"
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            ForEach(filteredLandlordProperties) { property in
                propertyLink(for: property)
            }
        }
    }

    /// Builds the navigation row for a single landlord-managed property.
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

    /// Returns the visible section heading for the currently selected listing status.
    private var sectionHeading: String {
        "\(selectedStatus.rawValue.capitalized) Listings"
    }

    /// Returns the empty-state title for the landlord's current listing filter.
    private var emptyStateTitle: String {
        landlordProperties.isEmpty
            ? "No Listings Yet"
            : "No \(selectedStatus.rawValue.capitalized) Listings"
    }

    /// Returns the empty-state message for the landlord's current listing filter.
    private var emptyStateMessage: String {
        if landlordProperties.isEmpty {
            return
                "Properties you create for this landlord account will appear here."
        }

        return
            "Properties with a \(selectedStatus.rawValue) status will appear here."
    }

    /// Provides a stable identity for scroll content refreshes when the
    /// selected filter changes.
    private var listingSectionIdentity: String {
        filteredLandlordProperties.map(\.propertyId).joined(separator: "|")
    }

    /// Returns every property owned by the current landlord from the shared
    /// property store.
    private var landlordProperties: [Property] {
        propertyStore.properties.filter { $0.landlordId == landlordId }
    }

    /// Narrows the landlord's properties to the currently selected status.
    private var filteredLandlordProperties: [Property] {
        landlordProperties.filter { $0.status == selectedStatus }
    }

}
