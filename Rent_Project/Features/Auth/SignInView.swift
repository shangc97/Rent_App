//
//  SignInView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        Form {
            Section("Credentials") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)

                Toggle("Remember Me", isOn: $rememberMe)
            }

            Section("Demo Sign In") {
                Button("Sign In as Tenant") {
                    appState.signIn(as: .tenant)
                }

                Button("Sign In as Landlord") {
                    appState.signIn(as: .landlord)
                }
            }

            Section("What comes later") {
                Text(
                    "FirebaseAuth and UserDefaults will replace these demo buttons in Modules 4 and 5."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Section {
                HStack(spacing: 4) {
                    Spacer()

                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)

                    NavigationLink("Sign Up") {
                        SignUpView()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Sign In") {
    NavigationStack {
        SignInView()
    }
    .environment(AppState.preview(sessionState: .loggedOut))
}
