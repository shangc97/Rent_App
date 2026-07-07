//
//  GuestPropertySearchTab.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct GuestPropertySearchTab: View {
    var body: some View {
        PropertySearchView(
            navigationTitle: "Search Property",
            helperText: "This tab is the future guest search flow. It will later connect to Firestore queries and filters."
        )
    }
}

#Preview("Guest Search Tab") {
    NavigationStack {
        GuestPropertySearchTab()
    }
}
