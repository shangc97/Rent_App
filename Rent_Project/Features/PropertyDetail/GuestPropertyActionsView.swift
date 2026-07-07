//
//  GuestPropertyActionsView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

struct GuestPropertyActionsView: View {
    var body: some View {
        Section("Guest Actions") {
            Text(
                "Guests can explore and share property details, but need an account to save listings or submit rental requests."
            )
            .foregroundStyle(.secondary)

            NavigationLink("Log In to Continue") {
                LoginView()
            }

            NavigationLink("Register an Account") {
                RegisterView()
            }
        }
    }
}

#Preview("Guest Property Actions") {
    NavigationStack {
        List {
            GuestPropertyActionsView()
        }
    }
    .environment(AppState.preview(sessionState: .guest))
}
