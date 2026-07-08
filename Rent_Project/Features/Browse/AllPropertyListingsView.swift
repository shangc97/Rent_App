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
    @Environment(PropertyStore.self) private var propertyStore

    var body: some View {
        List { listContent }
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

    /// Chooses between the empty state and the full listing section.
    @ViewBuilder
    private var listContent: some View {
        if properties.isEmpty {
            emptyState
        } else {
            propertySection
        }
    }

    /// Displays the placeholder content shown when no listings are available.
    private var emptyState: some View {
        EmptyStateView(
            title: "No Property Listings",
            message: "All available property listings will appear here.",
            systemImage: "building.2"
        )
    }

    /// Displays the section that contains every available property row.
    private var propertySection: some View {
        Section("All Property Listings") {
            ForEach(properties) { property in
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
        }
    }
}
