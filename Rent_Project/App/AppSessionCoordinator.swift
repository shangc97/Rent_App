//
//  AppSessionCoordinator.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import Foundation
import Security

/// Coordinates app-wide session flows that span multiple stores.
@MainActor
enum AppSessionCoordinator {
    private static let rememberedUserIdKey = "remembered_user_id"
    private static let rememberedUserEmailKey = "remembered_user_email"
    private static let keychainService = "shangc.Rent-Project.remember-me"

    /// A lightweight container for the credentials used to prefill the sign-in form.
    struct RememberedCredentials {
        let userId: String
        let email: String
        let password: String
    }

    /// Loads the signed-in user's profile and promotes it into `AppState`.
    ///
    /// - Parameters:
    ///   - userId: The authenticated Firebase user ID.
    ///   - appState: The shared app session state.
    ///   - userProfileStore: The profile store used to resolve the signed-in role.
    /// - Returns: `true` when the user profile is loaded and the authenticated
    ///   session is fully activated; otherwise `false`.
    @discardableResult
    static func activateAuthenticatedSession(
        userId: String,
        appState: AppState,
        userProfileStore: UserProfileStore
    ) async -> Bool {
        await userProfileStore.loadUserProfile(userId: userId)

        guard
            let currentUserProfile = userProfileStore.currentUserProfile,
            currentUserProfile.userId == userId
        else {
            return false
        }

        appState.setAuthenticatedSession(
            userId: currentUserProfile.userId,
            role: currentUserProfile.role
        )

        return true
    }

    /// Prepares the app's initial launch state before the auth landing flow appears.
    ///
    /// The app now always opens on the auth landing screen after launch, while
    /// remember-me only repopulates the sign-in fields instead of silently
    /// restoring an authenticated session.
    static func prepareLaunchSessionIfNeeded(
        appState: AppState,
        authStore: AuthStore,
        userProfileStore: UserProfileStore
    ) async {
        guard appState.sessionState == .loading else { return }

        authStore.restoreSession()

        if authStore.currentUserId != nil {
            authStore.signOut()
        }

        userProfileStore.clearUserProfile()
        appState.showLoggedOut()
    }

    /// Activates a guest session and clears any user-scoped data from memory.
    static func activateGuestSession(
        appState: AppState,
        userProfileStore: UserProfileStore,
        shortlistPropertyStore: ShortlistPropertyStore,
        rentalRequestStore: RentalRequestStore
    ) {
        clearUserScopedStores(
            userProfileStore: userProfileStore,
            shortlistPropertyStore: shortlistPropertyStore,
            rentalRequestStore: rentalRequestStore
        )
        appState.continueAsGuest()
    }

    /// Stores or clears the remembered credentials used to prefill sign-in.
    static func updateRememberedCredentials(
        userId: String,
        email: String,
        password: String,
        shouldRememberUser: Bool
    ) {
        if shouldRememberUser {
            clearRememberedCredentials()
            UserDefaults.standard.set(userId, forKey: rememberedUserIdKey)
            UserDefaults.standard.set(email, forKey: rememberedUserEmailKey)
            saveRememberedPassword(password, for: userId)
        } else {
            clearRememberedCredentials()
        }
    }

    /// Returns remembered credentials when the user previously opted in.
    static func rememberedCredentials() -> RememberedCredentials? {
        guard
            let userId = UserDefaults.standard.string(forKey: rememberedUserIdKey),
            let email = UserDefaults.standard.string(
                forKey: rememberedUserEmailKey
            ),
            let password = rememberedPassword(for: userId)
        else {
            return nil
        }

        return RememberedCredentials(
            userId: userId,
            email: email,
            password: password
        )
    }

    /// Signs out the current user and clears user-scoped data from shared stores.
    ///
    /// - Returns: `true` when sign-out succeeds and the app is transitioned to
    ///   the logged-out state; otherwise `false`.
    @discardableResult
    static func signOutCurrentSession(
        appState: AppState,
        authStore: AuthStore,
        userProfileStore: UserProfileStore,
        shortlistPropertyStore: ShortlistPropertyStore,
        rentalRequestStore: RentalRequestStore
    ) -> Bool {
        authStore.signOut()

        guard authStore.errorMessage == nil else { return false }

        clearUserScopedStores(
            userProfileStore: userProfileStore,
            shortlistPropertyStore: shortlistPropertyStore,
            rentalRequestStore: rentalRequestStore
        )
        appState.showLoggedOut()

        return true
    }

    /// Clears in-memory data that should not survive user or guest session changes.
    private static func clearUserScopedStores(
        userProfileStore: UserProfileStore,
        shortlistPropertyStore: ShortlistPropertyStore,
        rentalRequestStore: RentalRequestStore
    ) {
        userProfileStore.clearUserProfile()
        shortlistPropertyStore.clearShortlist()
        rentalRequestStore.clearRentalRequests()
    }

    /// Removes any remembered credentials from persistent storage.
    private static func clearRememberedCredentials() {
        if let rememberedUserId = UserDefaults.standard.string(
            forKey: rememberedUserIdKey
        ) {
            deleteRememberedPassword(for: rememberedUserId)
        }

        UserDefaults.standard.removeObject(forKey: rememberedUserIdKey)
        UserDefaults.standard.removeObject(forKey: rememberedUserEmailKey)
    }

    private static func saveRememberedPassword(
        _ password: String,
        for userId: String
    ) {
        deleteRememberedPassword(for: userId)

        guard let passwordData = password.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: userId,
            kSecValueData: passwordData,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private static func rememberedPassword(for userId: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: userId,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard
            status == errSecSuccess,
            let passwordData = result as? Data,
            let password = String(data: passwordData, encoding: .utf8)
        else {
            return nil
        }

        return password
    }

    private static func deleteRememberedPassword(for userId: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: userId,
        ]

        SecItemDelete(query as CFDictionary)
    }
}
