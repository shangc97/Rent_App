//
//  TenantHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

/// Hosts the tenant-facing tab navigation for browsing listings, managing the
/// shortlist, reviewing rental requests, searching properties, and viewing the
/// user profile.
struct TenantHomeView: View {
    /// Defines the tabs available in the tenant home experience.
    private enum TenantTab: Hashable {
        case allListings
        case shortlist
        case requests
        case search
        case profile
    }

    @State private var selectedTab: TenantTab = .allListings

    var body: some View {
        TabView(selection: $selectedTab) {
            AllPropertyListingsView()
                .tabItem {
                    Label("All Listings", systemImage: "square.grid.2x2")
                }
                .tag(TenantTab.allListings)

            TenantShortlistView()
                .tabItem {
                    Label("Shortlist", systemImage: "heart")
                }
                .tag(TenantTab.shortlist)

            TenantRequestsView()
                .tabItem {
                    Label("Requests", systemImage: "envelope")
                }
                .tag(TenantTab.requests)

            PropertySearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TenantTab.search)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(TenantTab.profile)
        }
    }
}
