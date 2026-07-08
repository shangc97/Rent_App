//
//  RootView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(PropertyStore.self) private var propertyStore
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
            await restoreSessionIfNeeded()
            if propertyStore.properties.isEmpty {
                await propertyStore.loadAllProperties()
            }
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

    private func restoreSessionIfNeeded() async {
        guard appState.sessionState == .loading else { return }

        authStore.restoreSession()

        guard let userId = authStore.currentUserId else {
            appState.showLoggedOut()
            return
        }

        await userProfileStore.loadUserProfile(userId: userId)

        guard let currentUserProfile = userProfileStore.currentUserProfile else {
            appState.showLoggedOut()
            return
        }

        appState.setAuthenticatedSession(
            userId: currentUserProfile.userId,
            role: currentUserProfile.role
        )
    }
}
