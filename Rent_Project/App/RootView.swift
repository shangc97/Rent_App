//
//  RootView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

/// The single root entry point that switches between loading, auth, guest,
/// tenant, and landlord app flows.
struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(UserProfileStore.self) private var userProfileStore

    var body: some View {
        Group {
            if appState.sessionState == .loading {
                LoadingView()
            } else {
                postLoadingView
            }
        }
        .task {
            await AppSessionCoordinator.prepareLaunchSessionIfNeeded(
                appState: appState,
                authStore: authStore,
                userProfileStore: userProfileStore
            )
        }
        .animation(.default, value: appState.sessionState)
    }

    /// Resolves the appropriate top-level navigation stack for the current session.
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
