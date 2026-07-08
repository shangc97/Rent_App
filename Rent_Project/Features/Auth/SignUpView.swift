//
//  SignUpView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct SignUpView: View {
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

            Section("Demo Sign Up") {
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

                    NavigationLink("Sign In") {
                        SignInView()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Sign Up") {
    NavigationStack {
        SignUpView()
    }
    .environment(AppState.preview(sessionState: .loggedOut))
}
