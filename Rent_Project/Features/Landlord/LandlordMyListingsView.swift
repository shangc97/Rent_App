//
//  LandlordMyListingsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Shows the signed-in landlord's properties, grouped by status, and supports
/// unlisting active properties after confirmation.
struct LandlordMyListingsView: View {
    @Environment(PropertyStore.self) private var propertyStore
    let landlordId: String
    @State private var pendingUnlisting: Property?
    @State private var selectedStatusFilter: PropertyStatus = .listed

    /// Displays the landlord's filtered listing set and unlisting confirmation flow.
    var body: some View {
        List {
            filterSection

            if filteredLandlordProperties.isEmpty {
                EmptyStateView(
                    title: emptyStateTitle,
                    message: emptyStateMessage,
                    systemImage: "building.2"
                )
            } else {
                Section(sectionTitle) {
                    ForEach(filteredLandlordProperties) { property in
                        NavigationLink {
                            PropertyDetailsView(property: property)
                        } label: {
                            PropertyRowView(property: property)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if property.status == .listed {
                                Button {
                                    pendingUnlisting = property
                                } label: {
                                    Label("Unlist", systemImage: "eye.slash")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("My Listings")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: landlordId) {
            await propertyStore.loadAllPropertiesIfNeeded()
        }
        .alert(
            "Unlist Property?",
            isPresented: isUnlistAlertPresented,
            presenting: pendingUnlisting
        ) { property in
            Button("Cancel", role: .cancel) {
                pendingUnlisting = nil
            }
            Button("Unlist") {
                pendingUnlisting = nil
                Task {
                    var updatedProperty = property
                    updatedProperty.status = .unlisted

                    await propertyStore.updateProperty(
                        propertyId: property.propertyId,
                        property: updatedProperty
                    )
                }
            }
        } message: { property in
            Text(
                "Are you sure you want to unlist \(property.address.streetAddress)? This property will no longer appear as an available listing."
            )
        }
    }

    /// Renders the segmented property-status picker shown above the listing results.
    private var filterSection: some View {
        Section {
            Picker("Status", selection: $selectedStatusFilter) {
                ForEach(PropertyStatus.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized)
                        .tag(status)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    /// Bridges the optional pending-unlist property into a Boolean alert binding.
    private var isUnlistAlertPresented: Binding<Bool> {
        Binding(
            get: { pendingUnlisting != nil },
            set: { isPresented in
                if !isPresented {
                    pendingUnlisting = nil
                }
            }
        )
    }

    /// Returns the section title for the currently selected listing status.
    private var sectionTitle: String {
        "\(selectedStatusFilter.rawValue.capitalized) Listings"
    }

    /// Returns the empty-state title for the landlord's current listing filter.
    private var emptyStateTitle: String {
        landlordProperties.isEmpty
            ? "No Listings Yet"
            : "No \(selectedStatusFilter.rawValue.capitalized) Listings"
    }

    /// Returns the empty-state message for the landlord's current listing filter.
    private var emptyStateMessage: String {
        if landlordProperties.isEmpty {
            return "Tap the add button in the top-right corner to create your first property listing."
        }

        return "Properties with a \(selectedStatusFilter.rawValue) status will appear here."
    }

    /// Returns every property owned by the current landlord from the shared
    /// property store.
    private var landlordProperties: [Property] {
        propertyStore.properties.filter { $0.landlordId == landlordId }
    }

    /// Narrows the landlord's properties to the currently selected status.
    private var filteredLandlordProperties: [Property] {
        landlordProperties.filter { $0.status == selectedStatusFilter }
    }
}
