//
//  AllPropertyListingsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Displays the full set of currently available property listings and routes
/// each result into its detail screen.
struct AllPropertyListingsView: View {
    /// Defines the property-status filter shown at the top of the page.
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
                "No Listed Properties"
            case .unlisted:
                "No Unlisted Properties"
            case .rented:
                "No Rented Properties"
            }
        }

        var emptyStateMessage: String {
            switch self {
            case .listed:
                "Properties that are currently available for rent will appear here."
            case .unlisted:
                "Properties that are currently unlisted will appear here."
            case .rented:
                "Properties that are currently rented will appear here."
            }
        }
    }

    @Environment(PropertyStore.self) private var propertyStore
    @State private var selectedSection: ListingSection = .listed

    /// Lays out the status filter and the independently scrollable listings area.
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                listingFilterSection
                listingResultsSection
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
        .navigationTitle("Property Listings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await propertyStore.loadAllPropertiesIfNeeded()
        }
    }

    /// Returns the current property list from the shared store.
    private var properties: [Property] {
        propertyStore.properties
    }

    /// Returns only the properties that match the currently selected status.
    private var filteredProperties: [Property] {
        properties.filter { $0.status == selectedSection.status }
    }

    /// Keeps the segmented status picker fixed at the top of the page.
    private var listingFilterSection: some View {
        Picker("Property Status", selection: $selectedSection) {
            ForEach(ListingSection.allCases) { section in
                Text(section.title)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
    }

    /// Displays the framed results area and its independently scrollable
    /// property content.
    private var listingResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionHeading)
                .font(.headline)

            ScrollView {
                LazyVStack(spacing: 12) {
                    listingResultsContent
                }
                .padding(16)
                .id(listingSectionIdentity)
            }
            .scrollIndicators(.visible)
            .background(resultsBackground)
            .overlay(resultsBorder)
        }
    }

    /// Chooses between the empty state and the filtered property results.
    @ViewBuilder
    private var listingResultsContent: some View {
        if filteredProperties.isEmpty {
            EmptyStateView(
                title: selectedSection.emptyStateTitle,
                message: selectedSection.emptyStateMessage,
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

    /// Builds the navigation row for a single property listing.
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

    /// Returns the visible section heading for the currently selected status.
    private var sectionHeading: String {
        "\(selectedSection.title) Properties"
    }

    /// Provides a stable identity for scroll content refreshes when the
    /// selected filter changes.
    private var listingSectionIdentity: String {
        filteredProperties.map(\.propertyId).joined(separator: "|")
    }

    /// Provides the background card used behind the results scroll view.
    private var resultsBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
    }

    /// Provides the border used around the results scroll view container.
    private var resultsBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }

    /// Provides the card background used for each property result row.
    private var resultCardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground))
    }

    /// Provides the border used for each property result row.
    private var resultCardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }
}
