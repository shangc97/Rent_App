//
//  TenantRequestsTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct TenantRequestsTab: View {
    private let sampleRequests = [
        "Applied to Downtown Studio",
        "Pending response for Waterfront Apartment"
    ]

    var body: some View {
        List {
            Section("My Requests") {
                ForEach(sampleRequests, id: \.self) { request in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request)
                            .font(.headline)
                        Text("Request status tracking will live here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("What comes later") {
                Text(
                    "This tab will later load the tenant's submitted rental requests and approval progress."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("My Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Tenant Requests Tab") {
    NavigationStack {
        TenantRequestsTab()
    }
}
