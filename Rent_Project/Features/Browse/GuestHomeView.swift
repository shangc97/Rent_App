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
        case register
    }

    @State private var selectedTab: GuestTab = .listings

    var body: some View {
        TabView(selection: $selectedTab) {
            GuestPropertyListingsTab()
                .tabItem {
                    Label("Listings", systemImage: "building.2")
                }
                .tag(GuestTab.listings)

            GuestPropertySearchTab()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(GuestTab.search)

            RegisterView()
                .tabItem {
                    Label("Register", systemImage: "person.badge.plus")
                }
                .tag(GuestTab.register)
        }
    }
}

#Preview("Guest Home") {
    NavigationStack {
        GuestHomeView()
    }
    .environment(AppState.preview(sessionState: .guest))
}
