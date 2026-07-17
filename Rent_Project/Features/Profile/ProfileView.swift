//
//  ProfileView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import SwiftUI

/// Displays the signed-in user's current profile details and session actions.
struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(PropertyStore.self) private var propertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @State private var isPresentingAddProperty = false

    private var currentRole: AppUserRole? {
        appState.currentUserRole
    }

    private var navigationTitle: String {
        switch currentRole {
        case .tenant:
            "Tenant Profile"
        case .landlord:
            "Landlord Profile"
        case .none:
            "Profile"
        }
    }

    private var currentUserProfile: UserProfile? {
        userProfileStore.currentUserProfile
    }

    private var currentLandlordId: String? {
        appState.currentLandlordId
    }

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent(
                    "Full Name",
                    value: currentUserProfile?.fullName ?? "Not loaded"
                )
                LabeledContent(
                    "Email",
                    value: currentUserProfile?.email ?? "Not loaded"
                )
                LabeledContent(
                    "Phone",
                    value: currentUserProfile?.phoneNumber ?? "Not loaded"
                )
            }

            if currentRole != nil {
                Button("Log Out", role: .destructive) {
                    signOut()
                }
            }

            if let errorMessage = authStore.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if currentLandlordId != nil {
                    Button {
                        isPresentingAddProperty = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                if let currentUserProfile {
                    NavigationLink {
                        ProfileEditView(userProfile: currentUserProfile)
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddProperty) {
            if let currentLandlordId {
                NavigationStack {
                    LandlordAddPropertyView(
                        landlordId: currentLandlordId
                    ) { newProperty in
                        await propertyStore.addProperty(newProperty)
                    }
                }
            }
        }
        .task(id: appState.currentUserId) {
            guard let currentUserId = appState.currentUserId else { return }

            if userProfileStore.currentUserProfile?.userId != currentUserId {
                await userProfileStore.loadUserProfile(
                    userId: currentUserId
                )
            }
        }
    }

    private func signOut() {
        _ = AppSessionCoordinator.signOutCurrentSession(
            appState: appState,
            authStore: authStore,
            userProfileStore: userProfileStore,
            shortlistPropertyStore: shortlistPropertyStore,
            rentalRequestStore: rentalRequestStore
        )
    }
}
