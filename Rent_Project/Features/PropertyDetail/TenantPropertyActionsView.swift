//
//  TenantPropertyActionsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct TenantPropertyActionsView: View {
    @Binding var isShortlisted: Bool
    @Binding var hasSubmittedRequest: Bool

    var body: some View {
        Section("Tenant Actions") {
            Button {
                isShortlisted.toggle()
            } label: {
                Label(
                    isShortlisted ? "Remove from Shortlist" : "Add to Shortlist",
                    systemImage: isShortlisted ? "heart.fill" : "heart"
                )
            }

            Button {
                hasSubmittedRequest.toggle()
            } label: {
                Label(
                    hasSubmittedRequest ? "Withdraw Rental Request" : "Send Rental Request",
                    systemImage: "paperplane"
                )
            }

            Text(
                "This area will later connect to shortlist storage and tenant request submission."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview("Tenant Property Actions") {
    @Previewable @State var isShortlisted = false
    @Previewable @State var hasSubmittedRequest = false

    NavigationStack {
        List {
            TenantPropertyActionsView(
                isShortlisted: $isShortlisted,
                hasSubmittedRequest: $hasSubmittedRequest
            )
        }
    }
    .environment(
        AppState.preview(
            sessionState: .tenant,
            currentUserRole: .tenant,
            currentUserId: "demo-tenant"
        )
    )
}
