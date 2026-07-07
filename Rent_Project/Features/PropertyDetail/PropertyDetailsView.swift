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
    @State private var propertyStatus: PropertyStatus
    @State private var isShortlisted = false
    @State private var hasSubmittedRequest = false

    init(property: Property = .sample) {
        self.property = property
        _propertyStatus = State(initialValue: property.status)
    }

    var body: some View {
        List {
            PropertyDetailsContentView(
                property: displayProperty
            )

            roleSpecificActionsSection
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: displayProperty.shareSummary,
                    subject: Text(displayProperty.title),
                    message: Text("Sharing a property listing")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share property")
            }
        }
    }

    private var displayProperty: Property {
        var property = property
        property.status = propertyStatus
        return property
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
            LandlordPropertyActionsView(status: $propertyStatus)
        case .none:
            GuestPropertyActionsView()
        }
    }
}

//#Preview("Guest Property Details") {
//    NavigationStack {
//        PropertyDetailsView(property: .sample)
//    }
//    .environment(AppState.preview(sessionState: .guest))
//}
//
//#Preview("Tenant Property Details") {
//    NavigationStack {
//        PropertyDetailsView(property: .sample)
//    }
//    .environment(
//        AppState.preview(
//            sessionState: .tenant,
//            currentUserRole: .tenant,
//            currentUserId: "demo-tenant"
//        )
//    )
//}
//
//#Preview("Landlord Property Details") {
//    NavigationStack {
//        PropertyDetailsView(property: .sample)
//    }
//    .environment(
//        AppState.preview(
//            sessionState: .landlord,
//            currentUserRole: .landlord,
//            currentUserId: "demo-landlord"
//        )
//    )
//}
