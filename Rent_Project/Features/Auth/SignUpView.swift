//
//  SignUpView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import SwiftUI

/// Account creation screen for registering a new user profile and activating
/// the authenticated app session.
struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @FocusState private var isPasswordFieldFocused: Bool

    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var selectedRole: AppUserRole = .tenant
    @State private var localErrorMessage: String?

    private var errorMessage: String? {
        localErrorMessage ?? authStore.errorMessage
            ?? userProfileStore.errorMessage
    }

    var body: some View {
        Form {
            profileBasicsSection
            accountTypeSection
            createAccountButton

            if let errorMessage {
                errorSection(message: errorMessage)
            }

            signInLinkSection
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Profile

    private var profileBasicsSection: some View {
        Section("Profile Basics") {
            TextField("Full Name", text: $fullName)
                .autocorrectionDisabled()

            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            passwordField
        }
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            Group {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .focused($isPasswordFieldFocused)

            Button {
                isPasswordVisible.toggle()
                isPasswordFieldFocused = true
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Account Type

    private var accountTypeSection: some View {
        Section("Account Type") {
            Picker("Role", selection: $selectedRole) {
                ForEach(AppUserRole.allCases) { role in
                    Text(role.displayName).tag(role)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Create Account

    private var createAccountButton: some View {
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
    }

    private func createAccount() async {
        localErrorMessage = nil

        await authStore.createAccount(
            email: trimmedEmail,
            password: password
        )

        guard let userId = authStore.currentUserId else { return }

        let userProfile = UserProfile(
            userId: userId,
            email: trimmedEmail,
            fullName: trimmedFullName,
            role: selectedRole,
            phoneNumber: trimmedPhoneNumber
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

    private var trimmedFullName: String {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPhoneNumber: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSubmitting: Bool {
        authStore.isLoading || userProfileStore.isLoading
    }

    private var canCreateAccount: Bool {
        !trimmedFullName.isEmpty && !trimmedEmail.isEmpty && !password.isEmpty
    }

    private func errorSection(message: String) -> some View {
        Section("Error") {
            Text(message)
                .foregroundStyle(.red)
        }
    }

    // MARK: - Sign In

    private var signInLinkSection: some View {
        Section {
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundStyle(.secondary)

                Button("Back to Sign In") {
                    navigateToSignIn()
                }
                .fontWeight(.semibold)
                .buttonStyle(.plain)
            }
        }
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
}
