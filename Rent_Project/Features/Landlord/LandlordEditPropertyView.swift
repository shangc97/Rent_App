//
//  LandlordEditPropertyView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Presents the landlord edit-property form used to update an existing
/// listing.
struct LandlordEditPropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PropertyStore.self) private var propertyStore

    let property: Property
    let onSave: (Property) async -> Bool

    @State private var draft: LandlordPropertyDraft
    @State private var isShowingSaveConfirmation = false
    @State private var isSaving = false

    init(property: Property, onSave: @escaping (Property) async -> Bool) {
        self.property = property
        self.onSave = onSave
        _draft = State(initialValue: LandlordPropertyDraft(property: property))
    }

    var body: some View {
        LandlordPropertyFormView(
            draft: $draft,
            errorMessage: propertyStore.errorMessage
        )
        .navigationTitle("Edit Property")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isSaving)
        .alert(
            "Update Property?",
            isPresented: $isShowingSaveConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Update") {
                Task {
                    await confirmSave()
                }
            }
        } message: {
            Text(saveConfirmationMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(isSaving)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    isShowingSaveConfirmation = true
                }
                .disabled(updatedProperty == nil || isSaving)
            }
        }
    }

    private var updatedProperty: Property? {
        draft.buildProperty(
            propertyId: property.propertyId,
            landlordId: property.landlordId
        )
    }

    private var saveConfirmationMessage: String {
        guard let updatedProperty else {
            return "Please confirm that you want to save these property detail changes."
        }

        if property.status == .listed && updatedProperty.status != .listed {
            return "Please confirm that you want to save these property detail changes. Any submitted requests for this property will be withdrawn automatically."
        }

        return "Please confirm that you want to save these property detail changes."
    }

    @MainActor
    private func confirmSave() async {
        guard let updatedProperty, !isSaving else { return }

        isSaving = true
        let didSave = await onSave(updatedProperty)
        isSaving = false

        if didSave {
            dismiss()
        }
    }
}
