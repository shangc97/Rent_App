//
//  AllPropertyListingsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays properties by listing status and routes each result to its details.
struct AllPropertyListingsView: View {
    @Environment(PropertyStore.self) private var propertyStore

    @State private var selectedStatus: PropertyStatus = .listed

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

    private var listingFilterSection: some View {
        PropertyStatusFilterPicker(selection: $selectedStatus)
    }

    private var listingSectionIdentity: String {
        filteredProperties.map(\.propertyId).joined(separator: "|")
    }

    private var filteredProperties: [Property] {
        properties.filter { $0.status == selectedStatus }
    }

    private var properties: [Property] {
        propertyStore.properties
    }

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

    private var emptyStateTitle: String {
        "No \(selectedStatus.rawValue.capitalized) Properties"
    }

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
