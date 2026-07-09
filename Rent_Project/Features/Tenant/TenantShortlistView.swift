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
    /// Defines the shortlist status filters shown at the top of the page.
    private enum ListingSection: String, CaseIterable, Identifiable {
        case listed
        case unlisted
        case rented

        var id: String { rawValue }

        var title: String {
            rawValue.capitalized
        }

        var status: PropertyStatus {
            switch self {
            case .listed:
                .listed
            case .unlisted:
                .unlisted
            case .rented:
                .rented
            }
        }

        var emptyStateTitle: String {
            switch self {
            case .listed:
                "No Listed Shortlist Properties"
            case .unlisted:
                "No Unlisted Shortlist Properties"
            case .rented:
                "No Rented Shortlist Properties"
            }
        }

        var emptyStateMessage: String {
            switch self {
            case .listed:
                "Your shortlisted properties that are currently available for rent will appear here."
            case .unlisted:
                "Your shortlisted properties that are currently unlisted will appear here."
            case .rented:
                "Your shortlisted properties that are currently rented will appear here."
            }
        }
    }

    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore
    @State private var selectedSection: ListingSection = .listed

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                listingFilterSection
                shortlistResultsSection
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
        Picker("Property Status", selection: $selectedSection) {
            ForEach(ListingSection.allCases) { section in
                Text(section.title)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
    }

    private var shortlistResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionHeading)
                .font(.headline)

            ScrollView {
                LazyVStack(spacing: 12) {
                    shortlistResultsContent
                }
                .padding(16)
                .id(shortlistSectionIdentity)
            }
            .scrollIndicators(.visible)
            .background(resultsBackground)
            .overlay(resultsBorder)
        }
    }

    @ViewBuilder
    private var shortlistResultsContent: some View {
        if filteredShortlist.isEmpty {
            EmptyStateView(
                title: selectedSection.emptyStateTitle,
                message: selectedSection.emptyStateMessage,
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
        shortlist.filter { $0.status == selectedSection.status }
    }

    private var sectionHeading: String {
        "\(selectedSection.title) Shortlist"
    }

    private var shortlistSectionIdentity: String {
        filteredShortlist.map(\.propertyId).joined(separator: "|")
    }

    private func propertyLink(for property: Property) -> some View {
        NavigationLink {
            PropertyDetailsView(property: property)
        } label: {
            PropertyRowView(property: property)
                .padding(14)
                .background(resultCardBackground)
                .overlay(resultCardBorder)
        }
        .buttonStyle(.plain)
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
}
