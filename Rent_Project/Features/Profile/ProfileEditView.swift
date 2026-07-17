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

    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        _fullName = State(initialValue: userProfile.fullName)
        _phoneNumber = State(initialValue: userProfile.phoneNumber)
    }

    private var isSubmitting: Bool {
        userProfileStore.isLoading
    }

    private var trimmedFullName: String {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPhoneNumber: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedFullName.isEmpty && hasChanges && !isSubmitting
    }

    private var hasChanges: Bool {
        trimmedFullName != userProfile.fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) || trimmedPhoneNumber != userProfile.phoneNumber.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var errorMessage: String? {
        localErrorMessage ?? userProfileStore.errorMessage
    }

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

    private var editableInfoSection: some View {
        Section("Personal Info") {
            TextField("Full Name", text: $fullName)

            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)
        }
    }

    private var accountInfoSection: some View {
        Section("Account Info") {
            LabeledContent("Email", value: userProfile.email)
            LabeledContent("Role", value: userProfile.role.displayName)
        }
    }

    private func errorSection(message: String) -> some View {
        Section("Error") {
            Text(message)
                .foregroundStyle(.red)
        }
    }

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
