//
//  RootView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.sessionState == .loading {
                LoadingView()
            } else {
                postLoadingView
            }
        }
        .task {
            appState.bootstrapIfNeeded()
        }
        .animation(.default, value: appState.sessionState)
    }

    @ViewBuilder
    private var postLoadingView: some View {
        switch appState.sessionState {
        case .loading, .loggedOut:
            NavigationStack {
                AuthLandingView()
            }
        case .guest:
            NavigationStack {
                GuestHomeView()
            }
        case .tenant:
            NavigationStack {
                TenantHomeView()
            }
        case .landlord:
            NavigationStack {
                LandlordHomeView()
            }
        }
    }
}
