//
//  LandlordHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import SwiftUI

/// Hosts the landlord-facing tab navigation for browsing, listing management,
/// request review, property search, and profile access.
struct LandlordHomeView: View {
    @Environment(AppState.self) private var appState

    private enum LandlordTab: Hashable {
        case allListings
        case myListings
        case requests
        case search
        case profile
    }

    @State private var selectedTab: LandlordTab = .allListings

    var body: some View {
        Group {
            if let landlordId = appState.currentLandlordId {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        AllPropertyListingsView()
                    }
                        .tabItem {
                            Label("All Listings", systemImage: "square.grid.2x2")
                        }
                        .tag(LandlordTab.allListings)

                    NavigationStack {
                        LandlordMyListingsView(
                            landlordId: landlordId
                        )
                    }
                    .tabItem {
                        Label("My Listings", systemImage: "building.2")
                    }
                    .tag(LandlordTab.myListings)

                    NavigationStack {
                        LandlordRequestsView()
                    }
                        .tabItem {
                            Label("Requests", systemImage: "envelope")
                        }
                        .tag(LandlordTab.requests)

                    NavigationStack {
                        PropertySearchView()
                    }
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(LandlordTab.search)

                    NavigationStack {
                        ProfileView()
                    }
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(LandlordTab.profile)
                }
            } else {
                ContentUnavailableView(
                    "No Landlord Session",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text(
                        "Sign in as a landlord to manage listings and requests."
                    )
                )
            }
        }
    }
}
