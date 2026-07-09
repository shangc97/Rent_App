//
//  LandlordRequestsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the current landlord's rental requests, split into pending,
/// processed, and archived sections.
struct LandlordRequestsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore
    @State private var selectedSection: RentalRequestSection = .pending
    @State private var tenantProfilesById: [String: UserProfile] = [:]
    @State private var loadedLandlordId: String?

    private let userProfileRepository = UserProfileRepository()

    /// Renders the landlord request dashboard with segmented filtering by request state.
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
        .task(id: appState.currentLandlordId) {
            await propertyStore.loadAllPropertiesIfNeeded()

            guard let currentLandlordId = appState.currentLandlordId else {
                tenantProfilesById = [:]
                loadedLandlordId = nil
                rentalRequestStore.clearRentalRequests()
                return
            }

            if loadedLandlordId != currentLandlordId {
                tenantProfilesById = [:]
                loadedLandlordId = currentLandlordId
            }

            await rentalRequestStore.loadLandlordRentalRequests(
                landlordId: currentLandlordId
            )
        }
        .task(id: tenantProfileLoadIdentity) {
            await loadMissingTenantProfiles()
        }
    }

    /// Keeps the segmented request-state picker fixed at the top of the page.
    private var requestFilterSection: some View {
        RentalRequestSectionPicker(selection: $selectedSection)
    }

    /// Chooses between the empty state and the filtered request results.
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

    /// Returns only the requests addressed to the signed-in landlord.
    private var landlordRequests: [RentalRequest] {
        guard let currentLandlordId = appState.currentLandlordId else { return [] }

        return rentalRequestStore.rentalRequests
            .filter { $0.landlordId == currentLandlordId }
    }

    /// Filters the landlord's requests to the selected segmented section.
    private var filteredRequests: [RentalRequest] {
        landlordRequests.filter { selectedSection.includes($0.status) }
    }

    /// Joins each filtered request with its matching property for row rendering.
    private var requestListItems: [RequestListItem] {
        filteredRequests.compactMap { request in
            guard let property = property(for: request) else { return nil }

            return RequestListItem(
                request: request,
                property: property
            )
        }
    }

    /// Builds the visible request row for the currently selected section.
    private func requestRow(for item: RequestListItem) -> some View {
        ResultsCardView {
            Group {
                if selectedSection == .pending {
                    LandlordPendingRequestRowView(
                        property: item.property,
                        request: item.request,
                        tenant: tenant(for: item.request)
                    )
                } else {
                    LandlordRequestHistoryRowView(
                        property: item.property,
                        request: item.request,
                        tenant: tenant(for: item.request)
                    )
                }
            }
        }
    }

    /// Returns the visible section heading for the currently selected request state.
    private var sectionHeading: String {
        selectedSection.sectionHeading
    }

    /// Provides a stable identity for scroll content refreshes when the
    /// selected filter changes.
    private var requestSectionIdentity: String {
        requestListItems.map(\.id).joined(separator: "|")
    }

    /// Provides a stable identity for loading tenant profiles when the
    /// landlord request set changes.
    private var tenantProfileLoadIdentity: String {
        Array(Set(landlordRequests.map(\.tenantId)))
            .sorted()
            .joined(separator: "|")
    }

    /// Looks up the property associated with a landlord request.
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
            return "New tenant applications that pending for review will appear here."
        case .processed:
            return "Approved and rejected requests will appear here after you review them."
        case .archived:
            return "Withdrawn requests will appear here after they are archived."
        }
    }

    /// Returns the cached tenant profile for the request or a placeholder
    /// while the real profile is still loading.
    private func tenant(for request: RentalRequest) -> UserProfile {
        tenantProfilesById[request.tenantId] ?? UserProfile(
            userId: request.tenantId,
            email: "",
            fullName: "Tenant",
            role: .tenant,
            phoneNumber: ""
        )
    }

    /// Loads any missing tenant profiles needed to render the landlord request rows.
    @MainActor
    private func loadMissingTenantProfiles() async {
        let missingTenantIds = Array(
            Set(landlordRequests.map(\.tenantId))
        )
        .filter { tenantProfilesById[$0] == nil }
        .sorted()

        guard !missingTenantIds.isEmpty else { return }

        for tenantId in missingTenantIds {
            do {
                if let tenantProfile =
                    try await userProfileRepository.fetchUserProfile(
                        userId: tenantId
                    )
                {
                    tenantProfilesById[tenantId] = tenantProfile
                }
            } catch {
                continue
            }
        }
    }

    /// Wraps a request and its resolved property into a single list row model.
    private struct RequestListItem: Identifiable {
        let request: RentalRequest
        let property: Property

        var id: String { request.id }
    }

}
