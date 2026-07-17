//
//  LandlordAddPropertyView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Presents the landlord add-property form in a sheet-style flow for
/// creating new listings.
struct LandlordAddPropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PropertyStore.self) private var propertyStore

    let landlordId: String
    let onSave: (Property) async -> Bool

    @State private var draft = LandlordPropertyDraft()
    @State private var propertyId = "property-\(UUID().uuidString.lowercased())"
    @State private var isShowingSaveConfirmation = false
    @State private var isSaving = false

    var body: some View {
        LandlordPropertyFormView(
            draft: $draft,
            errorMessage: propertyStore.errorMessage
        )
        .navigationTitle("Add Property")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isSaving)
        .alert(
            "Save Property?",
            isPresented: $isShowingSaveConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                Task {
                    await confirmSave()
                }
            }
        } message: {
            Text("Please confirm that you want to create this property listing.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(isSaving)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    isShowingSaveConfirmation = true
                }
                .disabled(newProperty == nil || isSaving)
            }
        }
    }

    private var newProperty: Property? {
        draft.buildProperty(
            propertyId: propertyId,
            landlordId: landlordId
        )
    }

    @MainActor
    private func confirmSave() async {
        guard let property = newProperty, !isSaving else { return }

        isSaving = true
        let didSave = await onSave(property)
        isSaving = false

        if didSave {
            dismiss()
        }
    }
}
