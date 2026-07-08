//
//  SignUpView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var selectedRole: AppUserRole = .tenant
    @State private var localErrorMessage: String?

    private var isSubmitting: Bool {
        authStore.isLoading || userProfileStore.isLoading
    }

    private var canCreateAccount: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
    }

    private var errorMessage: String? {
        localErrorMessage ?? authStore.errorMessage
            ?? userProfileStore.errorMessage
    }

    var body: some View {
        Form {
            Section("Profile Basics") {
                TextField("Full Name", text: $fullName)

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)

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

            Button {
                Task {
                    await createAccount()
                }
            } label: {
                HStack {
                    Spacer()

                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }

                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canCreateAccount || isSubmitting)

            if let errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                HStack(spacing: 4) {
                    Spacer()

                    Text("Already have an account?")
                        .foregroundStyle(.secondary)

                    Button("Back to Sign In") {
                        navigateToSignIn()
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

    private func navigateToSignIn() {
        localErrorMessage = nil
        authStore.restoreSession()
        userProfileStore.clearUserProfile()

        if appState.sessionState == .guest {
            appState.showLoggedOut()
        } else {
            dismiss()
        }
    }

    private func createAccount() async {
        localErrorMessage = nil

        let normalizedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let normalizedFullName = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let normalizedPhoneNumber = phoneNumber.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        await authStore.createAccount(
            email: normalizedEmail,
            password: password
        )

        guard let userId = authStore.currentUserId else { return }

        let userProfile = UserProfile(
            userId: userId,
            email: normalizedEmail,
            fullName: normalizedFullName,
            role: selectedRole,
            phoneNumber: normalizedPhoneNumber
        )

        await userProfileStore.createUserProfile(userProfile)

        if userProfileStore.errorMessage != nil {
            authStore.signOut()
            return
        }

        let didActivateSession =
            await AppSessionCoordinator
            .activateAuthenticatedSession(
                userId: userId,
                appState: appState,
                userProfileStore: userProfileStore
            )

        guard didActivateSession else {
            localErrorMessage =
                "Could not load the user profile for this account."
            authStore.signOut()
            return
        }
    }
}
