//
//  TenantShortlistTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct TenantShortlistTab: View {
    @State private var shortlist = [
        Property.sampleCondo,
        Property.sampleTownhouse
    ]
    @State private var pendingDeletion: Property?

    var body: some View {
        List {
            Section("My Shortlist") {
                ForEach(shortlist) { property in
                    NavigationLink {
                        PropertyDetailsView(property: property)
                    } label: {
                        PropertyRowView(property: property)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            pendingDeletion = property
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            Section("What comes later") {
                Text(
                    "This tab will later show the tenant's saved shortlist and support add or remove actions."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("My Shortlist")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Remove from Shortlist?",
            isPresented: isDeleteAlertPresented,
            presenting: pendingDeletion
        ) { property in
            Button("Cancel", role: .cancel) {
                pendingDeletion = nil
            }
            Button("Delete", role: .destructive) {
                ///TODO: Delete
            }
        } message: { property in
            Text(
                "Are you sure you want to remove \(property.address.streetAddress) from your shortlist?"
            )
        }
    }

    private var isDeleteAlertPresented: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDeletion = nil
                }
            }
        )
    }
}

#Preview("Tenant Shortlist Tab") {
    NavigationStack {
        TenantShortlistTab()
    }
}
