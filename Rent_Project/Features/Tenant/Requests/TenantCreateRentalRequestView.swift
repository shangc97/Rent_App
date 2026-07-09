//
//  TenantCreateRentalRequestView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Lets a tenant compose and submit a rental request within the tenant
/// request flow.
struct TenantCreateRentalRequestView: View {
    /// Represents the alerts that can be shown during request submission.
    private enum ActiveAlert: Identifiable {
        case confirmSubmit
        case duplicatePendingRequest

        var id: String {
            switch self {
            case .confirmSubmit:
                "confirm-submit"
            case .duplicatePendingRequest:
                "duplicate-pending-request"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(RentalRequestStore.self) private var rentalRequestStore

    let property: Property

    @State private var requestMessage = ""
    @State private var activeAlert: ActiveAlert?

    var body: some View {
        Form {
            Section("Property") {
                Text(property.title)
                    .font(.headline)
                Text(property.address.fullAddress)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(property.formattedRent)
                    .font(.subheadline.weight(.semibold))
            }

            if let errorMessage = rentalRequestStore.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section {
                TextEditor(text: $requestMessage)
                    .frame(minHeight: 180)
            } header: {
                Text("Message")
            } footer: {
                Text("Tell the landlord why you are interested in this property.")
            }

            Section {
                Button {
                    Task {
                        await handleSubmitButtonTap()
                    }
                } label: {
                    HStack {
                        if rentalRequestStore.isLoading {
                            ProgressView()
                        }

                        Text("Submit Request")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!canSubmitRequest)
            }
        }
        .navigationTitle("New Request")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $activeAlert) { activeAlert in
            switch activeAlert {
            case .confirmSubmit:
                Alert(
                    title: Text("Confirm Request Submission"),
                    message: Text(
                        "Are you sure you want to submit this rental request?"
                    ),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .default(Text("Submit")) {
                        Task {
                            await submitRentalRequest()
                        }
                    }
                )
            case .duplicatePendingRequest:
                Alert(
                    title: Text("Request Already Pending"),
                    message: Text(
                        "You already have a pending request for this property."
                    ),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            rentalRequestStore.errorMessage = nil
        }
    }

    private var trimmedRequestMessage: String {
        requestMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSubmitRequest: Bool {
        appState.currentTenantId != nil
            && property.isListed
            && !trimmedRequestMessage.isEmpty
            && !rentalRequestStore.isLoading
    }

    @MainActor
    private func handleSubmitButtonTap() async {
        guard let currentTenantId = appState.currentTenantId else { return }

        let hasSubmittedRequest = await rentalRequestStore
            .tenantHasSubmittedRentalRequest(
                propertyId: property.propertyId,
                tenantId: currentTenantId
            )

        guard let hasSubmittedRequest else { return }

        activeAlert = hasSubmittedRequest
            ? .duplicatePendingRequest
            : .confirmSubmit
    }

    @MainActor
    private func submitRentalRequest() async {
        guard let currentTenantId = appState.currentTenantId else { return }

        let rentalRequest = RentalRequest(
            requestId: UUID().uuidString,
            propertyId: property.propertyId,
            tenantId: currentTenantId,
            landlordId: property.landlordId,
            status: .submitted,
            message: trimmedRequestMessage
        )

        let didSubmit = await rentalRequestStore.submitRentalRequest(
            rentalRequest,
            tenantId: currentTenantId
        )

        if didSubmit {
            dismiss()
        }
    }
}
