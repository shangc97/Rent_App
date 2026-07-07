//
//  LandlordHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct LandlordHomeView: View {
    private enum LandlordTab: Hashable {
        case listings
        case requests
        case search
        case profile
    }

    @State private var selectedTab: LandlordTab = .listings

    var body: some View {
        TabView(selection: $selectedTab) {
            LandlordPropertyListingsTab()
                .tabItem {
                    Label("Listings", systemImage: "building.2")
                }
                .tag(LandlordTab.listings)

            LandlordRequestsTab()
                .tabItem {
                    Label("Requests", systemImage: "envelope")
                }
                .tag(LandlordTab.requests)

            LandlordSearchTab()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(LandlordTab.search)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(LandlordTab.profile)
        }
    }
}

#Preview("Landlord Home") {
    NavigationStack {
        LandlordHomeView()
    }
    .environment(
        AppState.preview(
            sessionState: .landlord,
            currentUserRole: .landlord,
            currentUserId: "demo-landlord"
        )
    )
}
