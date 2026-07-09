//
//  PropertyDetailsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

/// Hosts the shared property details experience and switches the trailing
/// toolbar actions based on the current user's role.
struct PropertyDetailsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore

    let property: Property

    var body: some View {
        List {
            PropertyDetailsInfoView(property: currentProperty)
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: appState.currentTenantId) {
            guard let currentTenantId = appState.currentTenantId else { return }

            await shortlistPropertyStore.loadTenantShortlist(
                tenantId: currentTenantId
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                shareButton
                roleSpecificSecondaryToolbarButton
            }
        }
    }

    private var shareButton: some View {
        ShareLink(
            item: currentProperty.shareSummary,
            subject: Text(currentProperty.title),
            message: Text("Sharing a property listing")
        ) {
            Image(systemName: "square.and.arrow.up")
        }
    }

    @ViewBuilder
    private var roleSpecificSecondaryToolbarButton: some View {
        if let role = appState.currentUserRole {
            switch role {
            case .tenant:
                TenantPropertyToolbarActionsView(property: currentProperty)
            case .landlord:
                LandlordPropertyToolbarActionsView(property: currentProperty)
            }
        }
    }

    private var currentProperty: Property {
        propertyStore.properties.first(where: {
            $0.propertyId == property.propertyId
        }) ?? property
    }
}
