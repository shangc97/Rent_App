//
//  TenantRequestRowView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Renders a tenant request summary row, including its linked property,
/// current request status, and the tenant's submitted or withdrawal message.
struct TenantRequestRowView: View {
    @Environment(RentalRequestStore.self) private var rentalRequestStore

    let request: RentalRequest
    let property: Property
    @State private var isPresentingWithdrawalSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Label(property.title, systemImage: statusSymbol)
                        .font(.headline)
                    Text(property.address.fullAddress)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(request.status.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(statusColor.opacity(0.14))
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(messageTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(request.message)
                    .font(.footnote)
            }

            if request.status == .submitted {
                withdrawButton
            }
        }
        .padding(.vertical, 6)
        .sheet(isPresented: $isPresentingWithdrawalSheet) {
            TenantRequestWithdrawalSheetView(
                request: request,
                property: property
            ) {
                isPresentingWithdrawalSheet = false
            }
        }
    }

    /// Presents the withdrawal flow for a still-pending tenant request.
    private var withdrawButton: some View {
        Button(role: .destructive) {
            isPresentingWithdrawalSheet = true
        } label: {
            Label("Withdraw Request", systemImage: "arrow.uturn.backward.circle")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .disabled(rentalRequestStore.isLoading)
    }

    private var statusSymbol: String {
        switch request.status {
        case .submitted:
            "clock.badge"
        case .approved:
            "checkmark.circle"
        case .rejected:
            "xmark.circle"
        case .withdrawn:
            "archivebox"
        }
    }

    private var statusColor: Color {
        switch request.status {
        case .submitted:
            .orange
        case .approved:
            .green
        case .rejected:
            .red
        case .withdrawn:
            .gray
        }
    }

    private var messageTitle: String {
        switch request.status {
        case .withdrawn:
            "Withdrawal Message"
        case .submitted, .approved, .rejected:
            "Your Message"
        }
    }
}
