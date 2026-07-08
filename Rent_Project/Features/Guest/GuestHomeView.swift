//
//  GuestHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct GuestHomeView: View {
    private enum GuestTab: Hashable {
        case listings
        case search
        case signUp
    }

    @State private var selectedTab: GuestTab = .listings

    var body: some View {
        TabView(selection: $selectedTab) {
            AllPropertyListingsView(properties: Property.samples)
                .tabItem {
                    Label("Listings", systemImage: "building.2")
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

#Preview("Guest Home") {
    NavigationStack {
        GuestHomeView()
    }
    .environment(AppState.preview(sessionState: .guest))
}
