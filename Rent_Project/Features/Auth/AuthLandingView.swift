//
//  AuthLandingView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct AuthLandingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            VStack(spacing: 8) {
                Text("4Rent")
                    .font(.largeTitle.bold())

                Text("Start from one shared entry point, then branch by role.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                NavigationLink {
                    LoginView()
                } label: {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    RegisterView()
                } label: {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    appState.continueAsGuest()
                } label: {
                    Text("Continue as Guest")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 12)

            Text(
                "Part 1 focus: root navigation, shared auth entry, and role-based home switching."
            )
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Auth Landing") {
    NavigationStack {
        AuthLandingView()
    }
    .environment(AppState.preview(sessionState: .loggedOut))
}
