//
//  SignUpView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

/// Account creation screen for registering a new user profile and activating
/// the authenticated app session.
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

    /// Indicates whether sign-up or profile creation work is currently running.
    private var isSubmitting: Bool {
        authStore.isLoading || userProfileStore.isLoading
    }

    /// Returns the full name after trimming leading and trailing whitespace.
    private var trimmedFullName: String {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the email after trimming leading and trailing whitespace.
    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the phone number after trimming leading and trailing whitespace.
    private var trimmedPhoneNumber: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Determines whether the account creation action should be enabled.
    private var canCreateAccount: Bool {
        !trimmedFullName.isEmpty && !trimmedEmail.isEmpty && !password.isEmpty
    }

    /// Surfaces the most relevant error from local, auth, or profile state.
    private var errorMessage: String? {
        localErrorMessage ?? authStore.errorMessage
            ?? userProfileStore.errorMessage
    }

    /// Renders the sign-up form, role picker, and navigation back to sign-in.
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

    /// Groups the core profile and credential fields shown at the top of the form.
    private var profileBasicsSection: some View {
        Section("Profile Basics") {
            TextField("Full Name", text: $fullName)

            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
        }
    }

    /// Lets the user choose which role the new account should use.
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

    /// Renders the primary action that starts account creation.
    private var createAccountButton: some View {
        Button {
            Task {
                await createAccount()
            }
        } label: {
            createAccountButtonLabel
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!canCreateAccount || isSubmitting)
    }

    /// Displays the content shown inside the create-account button.
    private var createAccountButtonLabel: some View {
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

    /// Shows any sign-up related error without changing the surrounding form layout.
    private func errorSection(message: String) -> some View {
        Section("Error") {
            Text(message)
                .foregroundStyle(.red)
        }
    }

    /// Provides the route back to the sign-in entry flow.
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

    /// Resets temporary state and returns the user to the sign-in entry path.
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

    /// Creates auth credentials, persists the user profile, and activates the
    /// authenticated session if all steps succeed.
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
}
