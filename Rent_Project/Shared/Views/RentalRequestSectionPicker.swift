//
//  RentalRequestSectionPicker.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-09.
//

import SwiftUI

/// Defines the grouped request buckets shared by tenant and landlord dashboards.
enum RentalRequestSection: String, CaseIterable, Identifiable {
    case pending
    case processed
    case archived

    var id: String { rawValue }

    /// Returns the user-facing label used by the segmented picker.
    var title: String {
        switch self {
        case .pending:
            "Pending"
        case .processed:
            "Processed"
        case .archived:
            "Archived"
        }
    }

    /// Returns the section heading shown above the filtered request results.
    var sectionHeading: String {
        "\(title) Requests"
    }

    /// Indicates whether a specific request status belongs in this grouped section.
    func includes(_ status: RentalRequestStatus) -> Bool {
        switch self {
        case .pending:
            return status == .submitted
        case .processed:
            return status == .approved || status == .rejected
        case .archived:
            return status == .withdrawn
        }
    }
}

/// Renders the shared segmented request picker used across request dashboards.
struct RentalRequestSectionPicker: View {
    @Binding var selection: RentalRequestSection

    var body: some View {
        Picker("Request Type", selection: $selection) {
            ForEach(RentalRequestSection.allCases) { section in
                Text(section.title)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
    }
}
