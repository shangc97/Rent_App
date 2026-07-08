//
//  AuthLandingView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct AuthLandingView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(ShortlistPropertyStore.self) private var shortlistPropertyStore
    @Environment(RentalRequestStore.self) private var rentalRequestStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var hasLoadedRememberedCredentials = false
    @State private var localErrorMessage: String?

    private var isSubmitting: Bool {
        authStore.isLoading || userProfileStore.isLoading
    }

    private var canSignIn: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
    }

    private var errorMessage: String? {
        localErrorMessage ?? authStore.errorMessage
            ?? userProfileStore.errorMessage
    }

    var body: some View {
        ZStack {
            backgroundView

            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    highlightStrip
                    signInCard
                    guestSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadRememberedCredentialsIfNeeded()
        }
    }

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

    private var heroSection: some View {
        VStack(spacing: 16) {
            Text("Rental Workspace")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.blue.opacity(0.12))
                )

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
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.blue.opacity(0.18), radius: 18, y: 8)

                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("4Rent")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("One clean entry point for browsing homes, tracking requests, and returning to your rental journey.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 330)
            }
        }
        .padding(.top, 8)
    }

    private var highlightStrip: some View {
        HStack(spacing: 10) {
            highlightPill(
                title: "Browse",
                systemImage: "magnifyingglass"
            )
            highlightPill(
                title: "Shortlist",
                systemImage: "heart"
            )
            highlightPill(
                title: "Manage",
                systemImage: "building.2"
            )
        }
    }

    private var signInCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Label("Account Access", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.blue)

                Text("Welcome Back")
                    .font(.title3.weight(.semibold))

                Text("Sign in to continue browsing listings or managing your account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

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

            rememberMeSection

            if let errorMessage {
                errorBanner(message: errorMessage)
            }

            Button {
                Task {
                    await signIn()
                }
            } label: {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
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

            NavigationLink {
                SignUpView()
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "person.badge.plus")
                    Text("Create a New Account")
                        .fontWeight(.semibold)
                    Spacer()
                }
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
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: 10)
    }

    private var rememberMeSection: some View {
        Toggle(isOn: $rememberMe) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Remember Me")
                    .font(.subheadline.weight(.semibold))

                Text("Prefill your email and password the next time this app opens on this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.9))
        )
    }

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

                Text("Continue as a guest to view listings first. You can create or sign in to an account when you're ready.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    AppSessionCoordinator.activateGuestSession(
                        appState: appState,
                        userProfileStore: userProfileStore,
                        shortlistPropertyStore: shortlistPropertyStore,
                        rentalRequestStore: rentalRequestStore
                    )
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "person.crop.circle.badge.questionmark")
                        Text("Continue as Guest")
                            .fontWeight(.semibold)
                        Spacer()
                    }
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

    private func highlightPill(
        title: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.7))
        )
        .overlay {
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.65), lineWidth: 1)
        }
    }

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

    private func credentialField(
        placeholder: String,
        systemImage: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.blue)
                .frame(width: 18)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
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

    private func secureCredentialField(
        placeholder: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.blue)
                .frame(width: 18)

            SecureField(placeholder, text: $password)
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

    private func signIn() async {
        localErrorMessage = nil

        let normalizedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        await authStore.signIn(
            email: normalizedEmail,
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
            email: normalizedEmail,
            password: password,
            shouldRememberUser: rememberMe
        )
    }

    private func loadRememberedCredentialsIfNeeded() {
        guard !hasLoadedRememberedCredentials else { return }

        hasLoadedRememberedCredentials = true

        guard
            let rememberedCredentials = AppSessionCoordinator
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
