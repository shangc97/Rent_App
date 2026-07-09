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

    let property: Property
    @State private var isPresentingEditProperty = false

    var body: some View {
        Group {
            if shouldShowEditButton {
                editButton
            }
        }
        .sheet(isPresented: $isPresentingEditProperty) {
            if let currentLandlordId = appState.currentLandlordId {
                NavigationStack {
                    LandlordAddPropertyView(
                        landlordId: currentLandlordId,
                        propertyToEdit: property
                    ) { updatedProperty in
                        Task {
                            await propertyStore.updateProperty(
                                propertyId: property.propertyId,
                                property: updatedProperty
                            )
                        }
                    }
                }
            }
        }
    }

    private var editButton: some View {
        Button {
            isPresentingEditProperty = true
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }

    private var shouldShowEditButton: Bool {
        guard let currentLandlordId = appState.currentLandlordId else {
            return false
        }

        return currentLandlordId == property.landlordId
    }
}
