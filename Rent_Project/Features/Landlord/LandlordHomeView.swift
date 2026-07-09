//
//  LandlordHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

/// Hosts the landlord-facing tab navigation for browsing, listing management,
/// request review, property search, and profile access.
struct LandlordHomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(PropertyStore.self) private var propertyStore

    /// Defines the tabs available in the landlord home experience.
    private enum LandlordTab: Hashable {
        case allListings
        case myListings
        case requests
        case search
        case profile
    }

    @State private var selectedTab: LandlordTab = .allListings
    @State private var isPresentingAddProperty = false

    /// Switches between landlord tabs and exposes the add-listing entry point.
    var body: some View {
        Group {
            if let landlordId = appState.currentLandlordId {
                TabView(selection: $selectedTab) {
                    AllPropertyListingsView()
                        .tabItem {
                            Label("All Listings", systemImage: "square.grid.2x2")
                        }
                        .tag(LandlordTab.allListings)

                    LandlordMyListingsView(
                        landlordId: landlordId
                    )
                    .tabItem {
                        Label("My Listings", systemImage: "building.2")
                    }
                    .tag(LandlordTab.myListings)

                    LandlordRequestsView()
                        .tabItem {
                            Label("Requests", systemImage: "envelope")
                        }
                        .tag(LandlordTab.requests)

                    PropertySearchView()
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
                .toolbar {
                    if selectedTab == .myListings {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isPresentingAddProperty = true
                            } label: {
                                Label("Add Property", systemImage: "plus")
                            }
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAddProperty) {
                    NavigationStack {
                        LandlordAddPropertyView(landlordId: landlordId) { property in
                            Task {
                                await propertyStore.addProperty(property)
                            }
                        }
                    }
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
