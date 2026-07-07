//
//  TenantSearchTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct TenantSearchTab: View {
    var body: some View {
        PropertySearchView(
            navigationTitle: "Search",
            helperText: "Tenants can browse the market, compare options, and open property details from this tab."
        )
    }
}

#Preview("Tenant Search Tab") {
    NavigationStack {
        TenantSearchTab()
    }
}
