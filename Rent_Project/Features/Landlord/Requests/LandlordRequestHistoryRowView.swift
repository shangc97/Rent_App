//
//  LandlordRequestHistoryRowView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Renders a previously reviewed or archived landlord request in a compact
/// read-only row.
struct LandlordRequestHistoryRowView: View {
    let property: Property
    let request: RentalRequest
    let tenant: UserProfile?
    let isTenantProfileUnavailable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                tenantProfileLabel

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
                Label(property.title, systemImage: statusSymbol)
                    .font(.subheadline.weight(.semibold))
                Text(property.address.fullAddress)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var tenantProfileLabel: some View {
        if let tenant {
            Text(tenant.displayName)
                .font(.headline)
        } else if isTenantProfileUnavailable {
            Label(
                "Tenant profile unavailable",
                systemImage: "person.crop.circle.badge.exclamationmark"
            )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        } else {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Loading tenant profile...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statusSymbol: String {
        switch request.status {
        case .approved:
            return "checkmark.circle"
        case .rejected:
            return "xmark.circle"
        case .withdrawn:
            return "archivebox"
        case .submitted:
            return "clock.badge"
        }
    }

    private var statusColor: Color {
        switch request.status {
        case .approved:
            return .green
        case .rejected:
            return .red
        case .withdrawn:
            return .gray
        case .submitted:
            return .orange
        }
    }
}
