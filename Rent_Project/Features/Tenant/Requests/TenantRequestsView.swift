//
//  TenantRequestsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the current tenant's rental requests, grouped into pending,
/// processed, and archived sections with dedicated actions for withdrawal.
struct TenantRequestsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore
    @State private var selectedSection: RequestSection = .pending
    @State private var pendingWithdrawalItem: RequestListItem?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                requestFilterSection
                requestResultsSection
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
        .sheet(item: $pendingWithdrawalItem) { item in
            TenantRequestWithdrawalSheetView(
                request: item.request,
                property: item.property,
                onDismiss: dismissWithdrawalSheet
            )
        }
    }

    /// Keeps the segmented request picker fixed at the top of the page.
    private var requestFilterSection: some View {
        Picker("Request Type", selection: $selectedSection) {
            ForEach(RequestSection.allCases) { section in
                Text(section.title)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
    }

    /// Displays the framed request container whose content scrolls
    /// independently beneath the fixed picker.
    private var requestResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionHeading)
                .font(.headline)

            ScrollView {
                LazyVStack(spacing: 12) {
                    requestResultsContent
                }
                .padding(16)
                .id(requestSectionIdentity)
            }
            .scrollIndicators(.visible)
            .background(resultsBackground)
            .overlay(resultsBorder)
        }
    }

    /// Chooses between the empty state and the scrollable request rows.
    @ViewBuilder
    private var requestResultsContent: some View {
        if requestListItems.isEmpty {
            EmptyStateView(
                title: selectedSection.emptyStateTitle,
                message: selectedSection.emptyStateMessage,
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

    /// Builds a styled request card and preserves the existing withdraw swipe
    /// action for pending requests.
    private func requestRow(for item: RequestListItem) -> some View {
        TenantRequestRowView(
            request: item.request,
            property: item.property
        )
        .padding(14)
        .background(resultCardBackground)
        .overlay(resultCardBorder)
        .swipeActions(
            edge: .trailing,
            allowsFullSwipe: false
        ) {
            if item.request.status == .submitted {
                Button(role: .destructive) {
                    openWithdrawalSheet(for: item)
                } label: {
                    Label(
                        "Withdraw",
                        systemImage: "arrow.uturn.backward.circle"
                    )
                }
            }
        }
    }

    /// Defines the request buckets shown in the tenant request filter.
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
                "Requests you submit that are still waiting for review will appear here."
            case .processed:
                "Approved and denied requests will appear here after a landlord reviews them."
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
        "\(selectedSection.title) Requests"
    }

    private var resultsBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
    }

    private var resultsBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }

    private var resultCardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground))
    }

    private var resultCardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }

    private func property(for request: RentalRequest) -> Property? {
        propertyStore.properties.first { $0.propertyId == request.propertyId }
    }

    private func openWithdrawalSheet(for item: RequestListItem) {
        pendingWithdrawalItem = item
    }

    private func dismissWithdrawalSheet() {
        pendingWithdrawalItem = nil
    }

    /// Couples a rental request with its resolved property so the UI can render
    /// both pieces of data together.
    private struct RequestListItem: Identifiable {
        let request: RentalRequest
        let property: Property

        var id: String { request.id }
    }
}
