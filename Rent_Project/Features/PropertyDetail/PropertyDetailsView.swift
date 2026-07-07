//
//  PropertyDetailsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct PropertyDetailsView: View {
    @Environment(AppState.self) private var appState

    let property: Property
    @State private var isListed: Bool
    @State private var isShortlisted = false
    @State private var hasSubmittedRequest = false

    init(property: Property = .sample) {
        self.property = property
        _isListed = State(initialValue: property.isListed)
    }

    private var propertyStatusText: String {
        isListed ? "Available" : "Not Listed"
    }

    var body: some View {
        List {
            PropertyDetailsContentView(
                property: property,
                statusText: propertyStatusText
            )

            roleSpecificActionsSection
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: property.shareSummary,
                    subject: Text(property.title),
                    message: Text("Sharing a property listing")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share property")
            }
        }
    }

    @ViewBuilder
    private var roleSpecificActionsSection: some View {
        switch appState.currentUserRole {
        case .tenant:
            TenantPropertyActionsView(
                isShortlisted: $isShortlisted,
                hasSubmittedRequest: $hasSubmittedRequest
            )
        case .landlord:
            LandlordPropertyActionsView(isListed: $isListed)
        case .none:
            GuestPropertyActionsView()
        }
    }
}

#Preview("Guest Property Details") {
    NavigationStack {
        PropertyDetailsView(property: .sample)
    }
    .environment(AppState.preview(sessionState: .guest))
}

#Preview("Tenant Property Details") {
    NavigationStack {
        PropertyDetailsView(property: .sample)
    }
    .environment(
        AppState.preview(
            sessionState: .tenant,
            currentUserRole: .tenant,
            currentUserId: "demo-tenant"
        )
    )
}

#Preview("Landlord Property Details") {
    NavigationStack {
        PropertyDetailsView(property: .sample)
    }
    .environment(
        AppState.preview(
            sessionState: .landlord,
            currentUserRole: .landlord,
            currentUserId: "demo-landlord"
        )
    )
}
