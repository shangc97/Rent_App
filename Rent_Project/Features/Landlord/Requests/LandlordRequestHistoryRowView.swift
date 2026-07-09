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
    let tenant: UserProfile

    /// Displays the archived request summary for a previously handled request.
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(tenant.displayName)
                    .font(.headline)

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

    /// Returns the symbol that matches the request's resolved review status.
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

    /// Returns the accent color associated with the request's resolved review status.
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
