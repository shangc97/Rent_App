//
//  AuthLandingView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import SwiftUI

/// Shared authentication entry screen for sign-in, remembered credentials, and
/// guest access.
struct AuthLandingView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @FocusState private var isPasswordFieldFocused: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = false
    @State private var hasLoadedRememberedCredentials = false
    @State private var localErrorMessage: String?

    /// Indicates whether any authentication-related async work is still running.
    private var isSubmitting: Bool {
        authStore.isLoading || userProfileStore.isLoading
    }

    /// Returns the email value after trimming leading and trailing whitespace.
    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Determines whether the sign-in button should currently be enabled.
    private var canSignIn: Bool {
        !trimmedEmail.isEmpty && !password.isEmpty
    }

    /// Surfaces the most relevant error message from local, auth, or profile state.
    private var errorMessage: String? {
        localErrorMessage ?? authStore.errorMessage
            ?? userProfileStore.errorMessage
    }

    /// Lays out the sign-in card and guest entry point on the shared auth screen.
    var body: some View {
        ZStack {
            backgroundView

            ScrollView {
                VStack(spacing: 24) {
                    signInCard
                    guestSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navigationBrandTitle
            }
        }
        .onAppear {
            loadRememberedCredentialsIfNeeded()
        }
    }

    /// Renders the soft gradient and blurred shapes behind the auth content.
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.blue.opacity(0.08),
                Color.teal.opacity(0.06),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 180, height: 180)
                .blur(radius: 18)
                .offset(x: 60, y: -40)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Color.teal.opacity(0.14))
                .frame(width: 220, height: 220)
                .blur(radius: 26)
                .offset(x: -70, y: 90)
        }
    }

    /// Displays the compact 4Rent brand lockup in the navigation bar.
    private var navigationBrandTitle: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.95),
                                Color.cyan.opacity(0.8),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 30)

                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("4Rent")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
    }

    /// Wraps the main sign-in controls inside the styled glassmorphism card.
    private var signInCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            signInHeader
            credentialsSection
            rememberMeSection

            if let errorMessage {
                errorBanner(message: errorMessage)
            }

            signInButton
            signUpButton
        }
        .padding(24)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: 10)
    }

    /// Displays the section heading above the sign-in form controls.
    private var signInHeader: some View {
        Label(
            "Account Access",
            systemImage: "person.crop.circle.badge.checkmark"
        )
        .font(.title3.weight(.semibold))
        .foregroundStyle(Color.blue)
    }

    /// Groups the email and password fields with their shared layout spacing.
    private var credentialsSection: some View {
        VStack(spacing: 14) {
            labeledCredentialField(
                title: "Email Address",
                placeholder: "Enter your email",
                systemImage: "envelope",
                text: $email
            )

            labeledSecureCredentialField(
                title: "Password",
                placeholder: "Enter your password",
                systemImage: "lock"
            )
        }
    }

    /// Renders the primary sign-in action button.
    private var signInButton: some View {
        Button {
            Task {
                await signIn()
            }
        } label: {
            fullWidthButtonLabel(
                title: "Sign In",
                showsProgress: isSubmitting
            )
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(
                color: Color.blue.opacity(0.2),
                radius: 16,
                y: 8
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(!canSignIn || isSubmitting)
        .opacity((!canSignIn || isSubmitting) ? 0.6 : 1)
    }

    /// Renders the secondary action that opens the sign-up screen.
    private var signUpButton: some View {
        NavigationLink {
            SignUpView()
        } label: {
            fullWidthButtonLabel(
                title: "Create a New Account",
                systemImage: "person.badge.plus"
            )
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.blue.opacity(0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(isSubmitting)
        .opacity(isSubmitting ? 0.6 : 1)
    }

    /// Displays and stores the user's preference for remembered credentials.
    private var rememberMeSection: some View {
        Toggle(isOn: $rememberMe) {
            Text("Remember Me")
                .font(.subheadline.weight(.semibold))
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.9))
        )
    }

    /// Presents the alternative guest entry path below the main auth card.
    private var guestSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.18))
                    .frame(height: 1)

                Text("or")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Rectangle()
                    .fill(Color.secondary.opacity(0.18))
                    .frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Just exploring?")
                    .font(.headline)

                Text(
                    "Continue as a guest to view listings first."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                guestButton
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.55))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            }
        }
    }

    /// Renders the guest action button while preserving the current visual styling.
    private var guestButton: some View {
        Button {
            AppSessionCoordinator.activateGuestSession(
                appState: appState,
                userProfileStore: userProfileStore,
                shortlistPropertyStore: shortlistPropertyStore,
                rentalRequestStore: rentalRequestStore
            )
        } label: {
            fullWidthButtonLabel(
                title: "Continue as Guest",
                systemImage: "person.crop.circle.badge.questionmark"
            )
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(Color(.systemBackground).opacity(0.8))
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(isSubmitting)
        .opacity(isSubmitting ? 0.6 : 1)
    }

    /// Builds the centered label content shared by the full-width action buttons.
    private func fullWidthButtonLabel(
        title: String,
        systemImage: String? = nil,
        showsProgress: Bool = false
    ) -> some View {
        HStack {
            Spacer()

            if showsProgress {
                ProgressView()
                    .tint(.white)
            } else {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
    }

    /// Renders a labeled text field using the shared auth field styling.
    private func labeledCredentialField(
        title: String,
        placeholder: String,
        systemImage: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            credentialField(
                placeholder: placeholder,
                systemImage: systemImage,
                text: text
            )
        }
    }

    /// Renders a labeled secure field using the shared auth field styling.
    private func labeledSecureCredentialField(
        title: String,
        placeholder: String,
        systemImage: String,
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            secureCredentialField(
                placeholder: placeholder,
                systemImage: systemImage
            )
        }
    }

    /// Applies the shared visual treatment used by auth text input rows.
    private func inputFieldRow<Content: View>(
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.blue)
                .frame(width: 18)

            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.blue.opacity(0.08), lineWidth: 1)
        }
    }

    /// Renders the shared styled email input field.
    private func credentialField(
        placeholder: String,
        systemImage: String,
        text: Binding<String>
    ) -> some View {
        inputFieldRow(systemImage: systemImage) {
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
        }
    }

    /// Renders the shared styled password input field.
    private func secureCredentialField(
        placeholder: String,
        systemImage: String
    ) -> some View {
        inputFieldRow(systemImage: systemImage) {
            Group {
                if isPasswordVisible {
                    TextField(placeholder, text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    SecureField(placeholder, text: $password)
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

    /// Displays inline auth errors inside a lightweight red status banner.
    private func errorBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.red.opacity(0.08))
        )
    }

    /// Signs the user in, resolves the matching profile, and updates remember-me state.
    private func signIn() async {
        localErrorMessage = nil

        await authStore.signIn(
            email: trimmedEmail,
            password: password
        )

        guard let userId = authStore.currentUserId else { return }

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

        AppSessionCoordinator.updateRememberedCredentials(
            userId: userId,
            email: trimmedEmail,
            password: password,
            shouldRememberUser: rememberMe
        )
    }

    /// Loads remembered credentials once when the auth landing screen first appears.
    private func loadRememberedCredentialsIfNeeded() {
        guard !hasLoadedRememberedCredentials else { return }

        hasLoadedRememberedCredentials = true

        guard
            let rememberedCredentials =
                AppSessionCoordinator
                .rememberedCredentials()
        else {
            rememberMe = false
            return
        }

        email = rememberedCredentials.email
        password = rememberedCredentials.password
        rememberMe = true
    }
}
