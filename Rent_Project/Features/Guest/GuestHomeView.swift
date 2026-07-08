//
//  GuestHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

/// Root guest experience that lets unauthenticated users browse listings,
/// search properties, or move into sign-up.
struct GuestHomeView: View {
    /// Tabs available to a guest user inside the main guest tab container.
    private enum GuestTab: Hashable {
        case listings
        case search
        case signUp
    }

    /// Tracks the currently selected guest tab.
    @State private var selectedTab: GuestTab = .listings

    var body: some View {
        TabView(selection: $selectedTab) {
            AllPropertyListingsView()
                .tabItem {
                    Label("All Listings", systemImage: "square.grid.2x2")
                }
                .tag(GuestTab.listings)

            PropertySearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(GuestTab.search)

            SignUpView()
                .tabItem {
                    Label("Sign Up", systemImage: "person.badge.plus")
                }
                .tag(GuestTab.signUp)
        }
    }
}
