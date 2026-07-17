//
//  RentalRequestSectionPicker.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-09.
//

import SwiftUI

/// Defines the grouped request buckets shared by tenant and landlord dashboards.
enum RentalRequestSection: String, CaseIterable, Identifiable {
    case pending
    case processed
    case archived

    var id: String { rawValue }

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

    var sectionHeading: String {
        "\(title) Requests"
    }

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
