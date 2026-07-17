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
    @State private var unavailableTenantProfileIds: Set<String> = []
    @State private var loadedLandlordId: String?

    private let userProfileRepository = UserProfileRepository()

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
                unavailableTenantProfileIds = []
                loadedLandlordId = nil
                rentalRequestStore.clearRentalRequests()
                return
            }

            if loadedLandlordId != currentLandlordId {
                tenantProfilesById = [:]
                unavailableTenantProfileIds = []
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

    private var requestFilterSection: some View {
        RentalRequestSectionPicker(selection: $selectedSection)
    }

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

    private var landlordRequests: [RentalRequest] {
        guard let currentLandlordId = appState.currentLandlordId else { return [] }

        return rentalRequestStore.rentalRequests
            .filter { $0.landlordId == currentLandlordId }
    }

    private var filteredRequests: [RentalRequest] {
        landlordRequests.filter { selectedSection.includes($0.status) }
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

    private func requestRow(for item: RequestListItem) -> some View {
        ResultsCardView {
            Group {
                if selectedSection == .pending {
                    LandlordPendingRequestRowView(
                        property: item.property,
                        request: item.request,
                        tenant: tenant(for: item.request),
                        isTenantProfileUnavailable:
                            isTenantProfileUnavailable(for: item.request)
                    )
                } else {
                    LandlordRequestHistoryRowView(
                        property: item.property,
                        request: item.request,
                        tenant: tenant(for: item.request),
                        isTenantProfileUnavailable:
                            isTenantProfileUnavailable(for: item.request)
                    )
                }
            }
        }
    }

    private var sectionHeading: String {
        selectedSection.sectionHeading
    }

    private var requestSectionIdentity: String {
        requestListItems.map(\.id).joined(separator: "|")
    }

    private var tenantProfileLoadIdentity: String {
        Array(Set(landlordRequests.map(\.tenantId)))
            .sorted()
            .joined(separator: "|")
    }

    private func property(for request: RentalRequest) -> Property? {
        propertyStore.properties.first { $0.propertyId == request.propertyId }
    }

    private var emptyStateTitle: String {
        "No \(selectedSection.title) Requests"
    }

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

    private func tenant(for request: RentalRequest) -> UserProfile? {
        tenantProfilesById[request.tenantId]
    }

    private func isTenantProfileUnavailable(
        for request: RentalRequest
    ) -> Bool {
        unavailableTenantProfileIds.contains(request.tenantId)
    }

    @MainActor
    private func loadMissingTenantProfiles() async {
        let missingTenantIds = Array(
            Set(landlordRequests.map(\.tenantId))
        )
        .filter {
            tenantProfilesById[$0] == nil
                && !unavailableTenantProfileIds.contains($0)
        }
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
                } else {
                    unavailableTenantProfileIds.insert(tenantId)
                }
            } catch {
                unavailableTenantProfileIds.insert(tenantId)
            }
        }
    }

    private struct RequestListItem: Identifiable {
        let request: RentalRequest
        let property: Property

        var id: String { request.id }
    }

}
