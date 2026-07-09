//
//  TenantShortlistView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the signed-in tenant's shortlisted properties and lets them browse
/// the shortlist by current property status.
struct TenantShortlistView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore
    @State private var selectedStatus: PropertyStatus = .listed

    var body: some View {
        FixedTopScrollableResultsLayout(
            resultsTitle: sectionHeading,
            scrollIdentity: shortlistSectionIdentity
        ) {
            listingFilterSection
        } resultsContent: {
            shortlistResultsContent
        }
        .navigationTitle("My Shortlist")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: appState.currentTenantId) {
            await propertyStore.loadAllPropertiesIfNeeded()

            guard let currentTenantId = appState.currentTenantId else { return }

            await shortlistPropertyStore.loadTenantShortlist(
                tenantId: currentTenantId
            )
        }
    }

    private var listingFilterSection: some View {
        PropertyStatusFilterPicker(selection: $selectedStatus)
    }

    @ViewBuilder
    private var shortlistResultsContent: some View {
        if filteredShortlist.isEmpty {
            EmptyStateView(
                title: emptyStateTitle,
                message: emptyStateMessage,
                systemImage: "heart"
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            ForEach(filteredShortlist) { property in
                propertyLink(for: property)
            }
        }
    }

    private var shortlist: [Property] {
        let shortlistedPropertyIds = Set(
            shortlistPropertyStore.shortlistProperties.map(\.propertyId)
        )

        return propertyStore.properties.filter { property in
            shortlistedPropertyIds.contains(property.propertyId)
        }
    }

    private var filteredShortlist: [Property] {
        shortlist.filter { $0.status == selectedStatus }
    }

    private var sectionHeading: String {
        "\(selectedStatus.rawValue.capitalized) Shortlist"
    }

    private var shortlistSectionIdentity: String {
        filteredShortlist.map(\.propertyId).joined(separator: "|")
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

    /// Returns the empty-state title for the current shortlist status filter.
    private var emptyStateTitle: String {
        "No \(selectedStatus.rawValue.capitalized) Shortlist Properties"
    }

    /// Returns the empty-state message for the current shortlist status filter.
    private var emptyStateMessage: String {
        switch selectedStatus {
        case .listed:
            return "Your shortlisted properties that are currently available for rent will appear here."
        case .unlisted:
            return "Your shortlisted properties that are currently unlisted will appear here."
        case .rented:
            return "Your shortlisted properties that are currently rented will appear here."
        }
    }
}
