//
//  ProfileEditView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Lets a signed-in user update the editable fields of their stored profile.
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfileStore.self) private var userProfileStore

    let userProfile: UserProfile

    @State private var fullName: String
    @State private var phoneNumber: String
    @State private var localErrorMessage: String?

    /// Seeds the edit form with the user's current profile values.
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        _fullName = State(initialValue: userProfile.fullName)
        _phoneNumber = State(initialValue: userProfile.phoneNumber)
    }

    /// Indicates whether a profile save is currently in progress.
    private var isSubmitting: Bool {
        userProfileStore.isLoading
    }

    /// Returns the full name after trimming leading and trailing whitespace.
    private var trimmedFullName: String {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the phone number after trimming leading and trailing whitespace.
    private var trimmedPhoneNumber: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Determines whether the save action should currently be enabled.
    private var canSave: Bool {
        !trimmedFullName.isEmpty && hasChanges && !isSubmitting
    }

    /// Indicates whether any editable field differs from the persisted profile.
    private var hasChanges: Bool {
        trimmedFullName != userProfile.fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) || trimmedPhoneNumber != userProfile.phoneNumber.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    /// Surfaces the most relevant local or store-level error to the form.
    private var errorMessage: String? {
        localErrorMessage ?? userProfileStore.errorMessage
    }

    /// Renders the editable profile form and save action.
    var body: some View {
        Form {
            editableInfoSection
            accountInfoSection

            if let errorMessage {
                errorSection(message: errorMessage)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await saveProfile()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!canSave)
            }
        }
    }

    /// Groups the editable personal fields the user is allowed to update.
    private var editableInfoSection: some View {
        Section("Personal Info") {
            TextField("Full Name", text: $fullName)

            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)
        }
    }

    /// Displays read-only account fields that are not edited from this screen.
    private var accountInfoSection: some View {
        Section("Account Info") {
            LabeledContent("Email", value: userProfile.email)
            LabeledContent("Role", value: userProfile.role.displayName)
        }
    }

    /// Displays a profile-update error without changing the surrounding form layout.
    private func errorSection(message: String) -> some View {
        Section("Error") {
            Text(message)
                .foregroundStyle(.red)
        }
    }

    /// Persists the edited profile fields and dismisses on success.
    private func saveProfile() async {
        localErrorMessage = nil

        guard !trimmedFullName.isEmpty else {
            localErrorMessage = "Full name cannot be empty."
            return
        }

        var updatedUserProfile = userProfile
        updatedUserProfile.fullName = trimmedFullName
        updatedUserProfile.phoneNumber = trimmedPhoneNumber

        await userProfileStore.updateUserProfile(updatedUserProfile)

        if userProfileStore.errorMessage == nil {
            dismiss()
        }
    }
}
