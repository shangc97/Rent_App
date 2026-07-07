//
//  LandlordSearchTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct LandlordSearchTab: View {
    var body: some View {
        PropertySearchView(
            navigationTitle: "Search",
            helperText: "Landlords can also search the market and view property details from this tab."
        )
    }
}

#Preview("Landlord Search Tab") {
    NavigationStack {
        LandlordSearchTab()
    }
}
