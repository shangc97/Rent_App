//
//  LandlordPropertyActionsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct LandlordPropertyActionsView: View {
    @Binding var isListed: Bool

    var body: some View {
        Section("Landlord Actions") {
            Button {
                isListed.toggle()
            } label: {
                Label(
                    isListed ? "Mark as Unlisted" : "Relist Property",
                    systemImage: isListed ? "eye.slash" : "eye"
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
}

#Preview("Landlord Property Actions") {
    @Previewable @State var isListed = true

    NavigationStack {
        List {
            LandlordPropertyActionsView(isListed: $isListed)
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
