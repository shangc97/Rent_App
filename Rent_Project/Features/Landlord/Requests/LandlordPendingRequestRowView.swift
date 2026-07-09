//
//  LandlordPendingRequestRowView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Renders a pending rental request row and lets the landlord approve or deny
/// the request after a confirmation step.
struct LandlordPendingRequestRowView: View {
    @Environment(AppState.self) private var appState
    @Environment(RentalRequestStore.self) private var rentalRequestStore

    let property: Property
    let request: RentalRequest
    let tenant: UserProfile
    @State private var pendingDecision: ReviewDecision?
    @State private var isSubmittingDecision = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tenant.displayName)
                        .font(.headline)
                    Text("is waiting for your review")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Pending")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.orange.opacity(0.14))
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(property.title, systemImage: "house.fill")
                    .font(.subheadline.weight(.semibold))
                Text(property.address.fullAddress)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Tenant Message")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(request.message)
                    .font(.footnote)
            }

            HStack(spacing: 12) {
                Spacer()

                Button(role: .destructive) {
                    pendingDecision = .deny
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.red)
                        .frame(width: 100, height: 33)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 4,
                                style: .continuous
                            )
                            .fill(Color.red.opacity(0.12))
                        )
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 4,
                                style: .continuous
                            )
                            .stroke(Color.red.opacity(0.22), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(isSubmittingDecision)

                Spacer()

                Button {
                    pendingDecision = .approve
                } label: {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.green)
                        .frame(width: 100, height: 33)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 4,
                                style: .continuous
                            )
                            .fill(Color.green.opacity(0.12))
                        )
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 4,
                                style: .continuous
                            )
                            .stroke(Color.green.opacity(0.22), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(isSubmittingDecision)

                Spacer()
            }
        }
        .padding(.vertical, 6)
        .alert(
            "Confirm Review Decision",
            isPresented: isDecisionAlertPresented,
            presenting: pendingDecision
        ) { decision in
            Button("Cancel", role: .cancel) {
                pendingDecision = nil
            }
            Button(
                decision.confirmTitle,
                role: decision.confirmButtonRole
            ) {
                pendingDecision = nil
                Task {
                    await submitDecision(decision)
                }
            }
        } message: { decision in
            Text(decision.message)
        }
    }

    /// Defines the review actions a landlord can take on a pending request.
    private enum ReviewDecision {
        case deny
        case approve

        var confirmTitle: String {
            switch self {
            case .deny:
                return "Deny Request"
            case .approve:
                return "Approve Request"
            }
        }

        var message: String {
            switch self {
            case .deny:
                return "Are you sure you want to deny this rental request?"
            case .approve:
                return "Are you sure you want to approve this rental request?"
            }
        }

        var confirmButtonRole: ButtonRole? {
            switch self {
            case .deny:
                return .destructive
            case .approve:
                return nil
            }
        }
    }

    private var isDecisionAlertPresented: Binding<Bool> {
        Binding(
            get: { pendingDecision != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDecision = nil
                }
            }
        )
    }

    /// Submits the landlord's review decision to the rental request store.
    @MainActor
    private func submitDecision(_ decision: ReviewDecision) async {
        guard let currentLandlordId = appState.currentLandlordId else {
            return
        }

        isSubmittingDecision = true
        defer { isSubmittingDecision = false }

        switch decision {
        case .deny:
            await rentalRequestStore.denyRentalRequest(
                request,
                landlordId: currentLandlordId
            )
        case .approve:
            await rentalRequestStore.approveRentalRequest(
                request,
                landlordId: currentLandlordId
            )
        }
    }
}
