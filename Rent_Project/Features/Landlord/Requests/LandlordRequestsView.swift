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
    @State private var selectedSection: RequestSection = .pending

    var body: some View {
        List {
            Section {
                Picker("Request Type", selection: $selectedSection) {
                    ForEach(RequestSection.allCases) { section in
                        Text(section.title)
                            .tag(section)
                    }
                }
                .pickerStyle(.segmented)
            }

            if filteredRequests.isEmpty {
                EmptyStateView(
                    title: selectedSection.emptyStateTitle,
                    message: selectedSection.emptyStateMessage,
                    systemImage: "tray"
                )
            } else {
                Section {
                    ForEach(filteredRequests) { request in
                        if let property = property(for: request) {
                            let tenant = tenant(for: request)

                            if selectedSection == .pending {
                                LandlordPendingRequestRowView(
                                    property: property,
                                    request: request,
                                    tenant: tenant
                                )
                            } else {
                                LandlordRequestHistoryRowView(
                                    property: property,
                                    request: request,
                                    tenant: tenant
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("My Requests")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: appState.currentLandlordId) {
            await propertyStore.loadAllPropertiesIfNeeded()

            guard let currentLandlordId = appState.currentLandlordId else {
                rentalRequestStore.clearRentalRequests()
                return
            }

            await rentalRequestStore.loadLandlordRentalRequests(
                landlordId: currentLandlordId
            )
        }
    }

    /// Defines the segmented request groupings shown in the landlord review
    /// interface.
    private enum RequestSection: String, CaseIterable, Identifiable {
        case pending
        case processed
        case archived

        var id: String { rawValue }

        var title: String {
            switch self {
            case .pending:
                "Pending"
            case .processed:
                "Processed"
            case .archived:
                "Archived"
            }
        }

        var emptyStateTitle: String {
            switch self {
            case .pending:
                "No Pending Requests"
            case .processed:
                "No Processed Requests"
            case .archived:
                "No Archived Requests"
            }
        }

        var emptyStateMessage: String {
            switch self {
            case .pending:
                "New tenant applications that pending for review will appear here."
            case .processed:
                "Approved and rejected requests will appear here after you review them."
            case .archived:
                "Withdrawn requests will appear here after they are archived."
            }
        }

        func includes(_ status: RentalRequestStatus) -> Bool {
            switch self {
            case .pending:
                status == .submitted
            case .processed:
                status == .approved || status == .rejected
            case .archived:
                status == .withdrawn
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

    /// Looks up the property associated with a landlord request.
    private func property(for request: RentalRequest) -> Property? {
        propertyStore.properties.first { $0.propertyId == request.propertyId }
    }

    /// Provides a temporary tenant display model until tenant profiles are
    /// loaded as part of the request review flow.
    private func tenant(for request: RentalRequest) -> UserProfile {
        UserProfile(
            userId: request.tenantId,
            email: "",
            fullName: "Tenant",
            role: .tenant,
            phoneNumber: ""
        )
    }
}
