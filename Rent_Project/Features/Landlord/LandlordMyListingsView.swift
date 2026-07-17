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

    private var filterSection: some View {
        PropertyStatusFilterPicker(
            selection: $selectedStatus,
            title: "Status"
        )
    }

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

    private var sectionHeading: String {
        "\(selectedStatus.rawValue.capitalized) Listings"
    }

    private var emptyStateTitle: String {
        landlordProperties.isEmpty
            ? "No Listings Yet"
            : "No \(selectedStatus.rawValue.capitalized) Listings"
    }

    private var emptyStateMessage: String {
        if landlordProperties.isEmpty {
            return
                "Properties you create for this landlord account will appear here."
        }

        return
            "Properties with a \(selectedStatus.rawValue) status will appear here."
    }

    private var listingSectionIdentity: String {
        filteredLandlordProperties.map(\.propertyId).joined(separator: "|")
    }

    private var landlordProperties: [Property] {
        propertyStore.properties.filter { $0.landlordId == landlordId }
    }

    private var filteredLandlordProperties: [Property] {
        landlordProperties.filter { $0.status == selectedStatus }
    }

}
