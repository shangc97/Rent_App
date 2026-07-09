//
//  TenantRequestWithdrawalSheetView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Collects a tenant's withdrawal message and confirms the request withdrawal
/// before submitting it to the shared rental request store.
struct TenantRequestWithdrawalSheetView: View {
    @Environment(AppState.self) private var appState
    @Environment(RentalRequestStore.self) private var rentalRequestStore

    let request: RentalRequest
    let property: Property
    let onDismiss: () -> Void

    @State private var withdrawalMessage = ""
    @State private var isWithdrawalConfirmationPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Request") {
                    Text(property.title)
                        .font(.headline)
                    Text(property.address.fullAddress)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let errorMessage = rentalRequestStore.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    TextEditor(text: $withdrawalMessage)
                        .frame(minHeight: 140)
                } header: {
                    Text("Withdrawal Message")
                } footer: {
                    Text("Let the landlord know why you are withdrawing this request.")
                }
            }
            .navigationTitle("Withdraw Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissSheet()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Withdraw") {
                        isWithdrawalConfirmationPresented = true
                    }
                    .disabled(!canSubmitWithdrawal)
                }
            }
            .alert(
                "Confirm Withdrawal",
                isPresented: $isWithdrawalConfirmationPresented
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Withdraw", role: .destructive) {
                    Task {
                        await submitWithdrawal()
                    }
                }
            } message: {
                Text("Are you sure you want to withdraw this rental request?")
            }
        }
        .onAppear {
            rentalRequestStore.errorMessage = nil
        }
    }

    private var trimmedWithdrawalMessage: String {
        withdrawalMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSubmitWithdrawal: Bool {
        !trimmedWithdrawalMessage.isEmpty
            && !rentalRequestStore.isLoading
            && appState.currentTenantId != nil
    }

    private func dismissSheet() {
        rentalRequestStore.errorMessage = nil
        isWithdrawalConfirmationPresented = false
        withdrawalMessage = ""
        onDismiss()
    }

    @MainActor
    private func submitWithdrawal() async {
        guard let currentTenantId = appState.currentTenantId else { return }

        var updatedRequest = request
        updatedRequest.message = trimmedWithdrawalMessage

        let didWithdraw = await rentalRequestStore.withdrawRentalRequest(
            updatedRequest,
            tenantId: currentTenantId
        )

        if didWithdraw {
            dismissSheet()
        }
    }
}
