//
//  TenantHomeView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct TenantHomeView: View {
    private enum TenantTab: Hashable {
        case shortlist
        case requests
        case search
        case profile
    }

    @State private var selectedTab: TenantTab = .shortlist

    var body: some View {
        TabView(selection: $selectedTab) {
            TenantShortlistTab()
                .tabItem {
                    Label("Shortlist", systemImage: "heart")
                }
                .tag(TenantTab.shortlist)

            TenantRequestsTab()
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

#Preview("Tenant Home") {
    NavigationStack {
        TenantHomeView()
    }
    .environment(
        AppState.preview(
            sessionState: .tenant,
            currentUserRole: .tenant,
            currentUserId: "demo-tenant"
        )
    )
}
