//
//  RegisterView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct RegisterView: View {
    @Environment(AppState.self) private var appState
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: AppUserRole = .tenant

    var body: some View {
        Form {
            Section("Profile Basics") {
                TextField("Full Name", text: $fullName)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
            }

            Section("Account Type") {
                Picker("Role", selection: $selectedRole) {
                    ForEach(AppUserRole.allCases) { role in
                        Text(role.displayName).tag(role)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Demo Registration") {
                Button("Create Demo Account") {
                    appState.signIn(as: selectedRole)
                }
            }

            Section("What comes later") {
                Text(
                    "This screen is only shaping the flow for now. Real validation and Firebase account creation belong to Module 4."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Section {
                HStack(spacing: 4) {
                    Spacer()

                    Text("Already have an account?")
                        .foregroundStyle(.secondary)

                    NavigationLink("Log In") {
                        LoginView()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Register") {
    NavigationStack {
        RegisterView()
    }
    .environment(AppState.preview(sessionState: .loggedOut))
}
