//
//  TenantPropertyToolbarActionsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Provides tenant-specific property detail actions such as shortlist toggling
/// and starting the rental request flow.
struct TenantPropertyToolbarActionsView: View {
    @Environment(AppState.self) private var appState
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore

    let property: Property

    var body: some View {
        Group {
            favoriteButton
            requestButton
        }
    }

    private var favoriteButton: some View {
        Button {
            handleFavoriteButtonTap()
        } label: {
            Image(systemName: isShortlisted ? "heart.fill" : "heart")
        }
        .disabled(appState.currentTenantId == nil || shortlistPropertyStore.isLoading)
    }

    private var requestButton: some View {
        NavigationLink {
            TenantCreateRentalRequestView(property: property)
        } label: {
            Image(systemName: "paperplane")
        }
        .disabled(!canCreateRentalRequest)
    }

    private var isShortlisted: Bool {
        guard let currentTenantId = appState.currentTenantId else { return false }

        return shortlistPropertyStore.isPropertyShortlisted(
            propertyId: property.propertyId,
            tenantId: currentTenantId
        )
    }

    private var canCreateRentalRequest: Bool {
        appState.currentTenantId != nil && property.isListed
    }

    private var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private func handleFavoriteButtonTap() {
        guard let currentTenantId = appState.currentTenantId else { return }

        if isRunningForPreviews {
            if isShortlisted {
                shortlistPropertyStore.shortlistProperties.removeAll {
                    $0.propertyId == property.propertyId
                        && $0.tenantId == currentTenantId
                }
            } else {
                let shortlistProperty = ShortlistProperty(
                    shortlistPropertyId: "\(currentTenantId)_\(property.propertyId)",
                    tenantId: currentTenantId,
                    propertyId: property.propertyId
                )

                shortlistPropertyStore.shortlistProperties.insert(
                    shortlistProperty,
                    at: 0
                )
            }

            return
        }

        Task {
            if isShortlisted {
                await shortlistPropertyStore.removePropertyFromShortlist(
                    propertyId: property.propertyId,
                    tenantId: currentTenantId
                )
            } else {
                await shortlistPropertyStore.addPropertyToShortlist(
                    propertyId: property.propertyId,
                    tenantId: currentTenantId
                )
            }
        }
    }
}
