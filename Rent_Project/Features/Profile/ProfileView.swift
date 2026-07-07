//
//  ProfileView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    private var currentRole: AppUserRole? {
        appState.currentUserRole
    }

    private var roleName: String {
        currentRole?.displayName ?? "Guest"
    }

    private var propertyShortcutTitle: String {
        switch currentRole {
        case .landlord:
            "Open Managed Property"
        case .tenant, .none:
            "Open Sample Property"
        }
    }

    var body: some View {
        List {
            Section("Current Session") {
                LabeledContent(
                    "User ID",
                    value: appState.currentUserId ?? "Not signed in"
                )
                LabeledContent(
                    "Role",
                    value: roleName
                )
            }

            Section("Profile Status") {
                Text(
                    "Profile editing will be built in Module 6 after FirebaseAuth and Firestore are connected."
                )
                .foregroundStyle(.secondary)
            }

            Section("Navigation") {
                NavigationLink(propertyShortcutTitle) {
                    PropertyDetailsView()
                }
            }

            if currentRole != nil {
                Section("Session") {
                    Button("Log Out", role: .destructive) {
                        appState.logout()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Tenant Profile") {
    NavigationStack {
        ProfileView()
    }
    .environment(
        AppState.preview(
            sessionState: .tenant,
            currentUserRole: .tenant,
            currentUserId: "demo-tenant"
        )
    )
}

#Preview("Landlord Profile") {
    NavigationStack {
        ProfileView()
    }
    .environment(
        AppState.preview(
            sessionState: .landlord,
            currentUserRole: .landlord,
            currentUserId: "demo-landlord"
        )
    )
}
