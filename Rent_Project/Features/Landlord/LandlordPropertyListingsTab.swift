//
//  LandlordPropertyListingsTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct LandlordPropertyListingsTab: View {
    @State private var properties = Property.samples.filter {
        $0.landlordId == "demo-landlord"
    }
    @State private var pendingDeletion: Property?

    var body: some View {
        List {
            Section("Your Property Listing") {
                ForEach(properties) { property in
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
                    "This tab will grow into landlord property CRUD: add, edit, list, and delist properties."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("My Listings")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Delete Listing?",
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
                "Are you sure you want to delete \(property.address.streetAddress)? This action cannot be undone."
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

#Preview("Landlord Listings Tab") {
    NavigationStack {
        LandlordPropertyListingsTab()
    }
}
