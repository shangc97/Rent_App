//
//  LandlordRequestsTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct LandlordRequestsTab: View {
    private let sampleRequests = [
        "Request from Alex for Downtown Condo",
        "Request from Maya for Basement Suite"
    ]

    var body: some View {
        List {
            Section("Incoming Requests") {
                ForEach(sampleRequests, id: \.self) { request in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request)
                            .font(.headline)
                        Text("Approval and denial actions will live here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("What comes later") {
                Text(
                    "This tab will later load the landlord's incoming rental requests from Firestore."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("My Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Landlord Requests Tab") {
    NavigationStack {
        LandlordRequestsTab()
    }
}
