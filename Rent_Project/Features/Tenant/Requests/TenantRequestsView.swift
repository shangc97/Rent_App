//
//  TenantRequestsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the current tenant's rental requests, grouped into pending,
/// processed, and archived sections.
struct TenantRequestsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore
    @State private var selectedSection: RentalRequestSection = .pending

    var body: some View {
        FixedTopScrollableResultsLayout(
            resultsTitle: sectionHeading,
            scrollIdentity: requestSectionIdentity
        ) {
            requestFilterSection
        } resultsContent: {
            requestResultsContent
        }
        .navigationTitle("My Requests")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: appState.currentTenantId) {
            await propertyStore.loadAllPropertiesIfNeeded()

            guard let currentTenantId = appState.currentTenantId else {
                rentalRequestStore.clearRentalRequests()
                return
            }

            await rentalRequestStore.loadTenantRentalRequests(
                tenantId: currentTenantId
            )
        }
    }

    /// Keeps the segmented request picker fixed at the top of the page.
    private var requestFilterSection: some View {
        RentalRequestSectionPicker(selection: $selectedSection)
    }

    /// Chooses between the empty state and the scrollable request rows.
    @ViewBuilder
    private var requestResultsContent: some View {
        if requestListItems.isEmpty {
            EmptyStateView(
                title: emptyStateTitle,
                message: emptyStateMessage,
                systemImage: "tray"
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            ForEach(requestListItems) { item in
                requestRow(for: item)
            }
        }
    }

    /// Builds a styled request card for a single tenant request.
    private func requestRow(for item: RequestListItem) -> some View {
        ResultsCardView {
            TenantRequestRowView(
                request: item.request,
                property: item.property
            )
        }
    }

    private var tenantRequests: [RentalRequest] {
        guard let currentTenantId = appState.currentTenantId else { return [] }

        return rentalRequestStore.rentalRequests
            .filter { $0.tenantId == currentTenantId }
    }

    private var filteredRequests: [RentalRequest] {
        tenantRequests.filter { selectedSection.includes($0.status) }
    }

    private var requestListItems: [RequestListItem] {
        filteredRequests.compactMap { request in
            guard let property = property(for: request) else { return nil }

            return RequestListItem(
                request: request,
                property: property
            )
        }
    }

    private var requestSectionIdentity: String {
        requestListItems.map(\.id).joined(separator: "|")
    }

    private var sectionHeading: String {
        selectedSection.sectionHeading
    }

    private func property(for request: RentalRequest) -> Property? {
        propertyStore.properties.first { $0.propertyId == request.propertyId }
    }

    /// Returns the empty-state title for the currently selected request section.
    private var emptyStateTitle: String {
        "No \(selectedSection.title) Requests"
    }

    /// Returns the empty-state message for the currently selected request section.
    private var emptyStateMessage: String {
        switch selectedSection {
        case .pending:
            return "Requests you submit that are still waiting for review will appear here."
        case .processed:
            return "Approved and denied requests will appear here after a landlord reviews them."
        case .archived:
            return "Withdrawn requests will appear here after they are archived."
        }
    }

    /// Couples a rental request with its resolved property so the UI can render
    /// both pieces of data together.
    private struct RequestListItem: Identifiable {
        let request: RentalRequest
        let property: Property

        var id: String { request.id }
    }
}
