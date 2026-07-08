//
//  LandlordPropertyActionsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct LandlordPropertyActionsView: View {
    @Binding var status: PropertyStatus

    var body: some View {
        Section("Landlord Actions") {
            Button {
                status = status == .listed ? .unlisted : .listed
            } label: {
                Label(
                    actionTitle,
                    systemImage: status == .listed ? "eye.slash" : "eye"
                )
            }

            NavigationLink("Open Incoming Requests") {
                LandlordRequestsTab()
            }

            Text(
                "This area will later support listing management, edit tools, and request review for the landlord."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private var actionTitle: String {
        switch status {
        case .listed:
            "Mark as Unlisted"
        case .unlisted, .rented:
            "Relist Property"
        }
    }
}

#Preview("Landlord Property Actions") {
    @Previewable @State var status: PropertyStatus = .listed

    NavigationStack {
        List {
            LandlordPropertyActionsView(status: $status)
        }
    }
    .environment(
        AppState.preview(
            sessionState: .landlord,
            currentUserRole: .landlord,
            currentUserId: "demo-landlord"
        )
    )
}
