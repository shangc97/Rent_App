//
//  PropertyStatusFilterPicker.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-09.
//

import SwiftUI

/// Renders the shared segmented property-status picker used across listing views.
struct PropertyStatusFilterPicker: View {
    @Binding var selection: PropertyStatus

    let title: String

    init(
        selection: Binding<PropertyStatus>,
        title: String = "Property Status"
    ) {
        _selection = selection
        self.title = title
    }

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(PropertyStatus.allCases, id: \.self) { status in
                Text(status.rawValue.capitalized)
                    .tag(status)
            }
        }
        .pickerStyle(.segmented)
    }
}
