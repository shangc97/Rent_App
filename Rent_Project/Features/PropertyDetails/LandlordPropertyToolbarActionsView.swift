//
//  LandlordPropertyToolbarActionsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Provides landlord-specific property detail actions and only exposes editing
/// controls when the viewed property belongs to the signed-in landlord.
struct LandlordPropertyToolbarActionsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore

    let property: Property
    @State private var isPresentingEditProperty = false
    @State private var pendingListingAction: ListingAction?
    @State private var isSubmittingListingAction = false

    var body: some View {
        Group {
            if shouldShowEditButton {
                editButton
                if let listingAction {
                    listingStatusButton(for: listingAction)
                }
            }
        }
        .sheet(isPresented: $isPresentingEditProperty) {
            NavigationStack {
                LandlordEditPropertyView(property: property) { updatedProperty in
                    await propertyStore.updateProperty(
                        propertyId: property.propertyId,
                        property: updatedProperty,
                        previousStatus: property.status,
                        rentalRequestStore: rentalRequestStore
                    )
                }
            }
        }
        .alert(
            "Confirm Property Status Update",
            isPresented: isListingActionAlertPresented,
            presenting: pendingListingAction
        ) { action in
            Button("Cancel", role: .cancel) {
                pendingListingAction = nil
            }
            Button(
                action.confirmTitle,
                role: action.confirmButtonRole
            ) {
                pendingListingAction = nil
                Task {
                    await updatePropertyStatus(using: action)
                }
            }
        } message: { action in
            Text(action.message)
        }
    }

    /// Opens the landlord property form in edit mode for the current listing.
    private var editButton: some View {
        Button {
            isPresentingEditProperty = true
        } label: {
            Image(systemName: "square.and.pencil")
        }
        .disabled(propertyStore.isLoading || isSubmittingListingAction)
    }

    /// Presents the list or unlist action for the current property status.
    private func listingStatusButton(for action: ListingAction) -> some View {
        Button {
            pendingListingAction = action
        } label: {
            Image(systemName: action.systemImage)
        }
        .disabled(propertyStore.isLoading || isSubmittingListingAction)
    }

    /// Returns the status toggle action that is valid for the current property.
    private var listingAction: ListingAction? {
        switch property.status {
        case .listed:
            return .unlist
        case .unlisted:
            return .list
        case .rented:
            return nil
        }
    }

    /// Determines whether landlord-only actions should be shown for this detail page.
    private var shouldShowEditButton: Bool {
        guard let currentLandlordId = appState.currentLandlordId else {
            return false
        }

        return currentLandlordId == property.landlordId
    }

    /// Bridges the optional listing action into a Boolean alert binding.
    private var isListingActionAlertPresented: Binding<Bool> {
        Binding(
            get: { pendingListingAction != nil },
            set: { isPresented in
                if !isPresented {
                    pendingListingAction = nil
                }
            }
        )
    }

    /// Persists the landlord's chosen listed or unlisted status for the property.
    @MainActor
    private func updatePropertyStatus(using action: ListingAction) async {
        guard shouldShowEditButton else {
            return
        }

        isSubmittingListingAction = true
        defer { isSubmittingListingAction = false }

        var updatedProperty = property
        updatedProperty.status = action.updatedStatus

        await propertyStore.updateProperty(
            propertyId: property.propertyId,
            property: updatedProperty,
            previousStatus: property.status,
            rentalRequestStore: rentalRequestStore
        )
    }

    /// Defines the landlord status transitions supported by the toolbar.
    private enum ListingAction {
        case list
        case unlist

        var updatedStatus: PropertyStatus {
            switch self {
            case .list:
                return .listed
            case .unlist:
                return .unlisted
            }
        }

        var systemImage: String {
            switch self {
            case .list:
                return "eye"
            case .unlist:
                return "eye.slash"
            }
        }

        var confirmTitle: String {
            switch self {
            case .list:
                return "List Property"
            case .unlist:
                return "Unlist Property"
            }
        }

        var message: String {
            switch self {
            case .list:
                return "Are you sure you want to make this property visible in the listing flow again?"
            case .unlist:
                return "Are you sure you want to remove this property from the active listing flow? Any submitted requests for this property will be withdrawn automatically."
            }
        }

        var confirmButtonRole: ButtonRole? {
            switch self {
            case .list:
                return nil
            case .unlist:
                return .destructive
            }
        }
    }
}
