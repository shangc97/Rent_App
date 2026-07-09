//
//  AppState.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-01.
//

import Foundation
import Observation

/// Stores app-wide session state used by the root navigation layer.
@Observable
final class AppState {
    var currentUserId: String?
    var currentUserRole: AppUserRole?
    var sessionState: AppSessionState = .loading

    /// Indicates whether the active session belongs to a tenant.
    var isTenantSession: Bool {
        currentUserRole == .tenant && currentUserId != nil
    }

    /// Indicates whether the active session belongs to a landlord.
    var isLandlordSession: Bool {
        currentUserRole == .landlord && currentUserId != nil
    }

    /// Returns the current tenant ID when the active session is a tenant session.
    var currentTenantId: String? {
        guard isTenantSession else { return nil }
        return currentUserId
    }

    /// Returns the current landlord ID when the active session is a landlord session.
    var currentLandlordId: String? {
        guard isLandlordSession else { return nil }
        return currentUserId
    }

    /// Activates an authenticated session using a resolved user ID and role.
    func setAuthenticatedSession(userId: String, role: AppUserRole) {
        currentUserId = userId
        currentUserRole = role
        sessionState = role == .tenant ? .tenant : .landlord
    }

    /// Activates the guest flow and clears any authenticated identity.
    func continueAsGuest() {
        currentUserId = nil
        currentUserRole = nil
        sessionState = .guest
    }

    /// Returns the app to the logged-out state and clears authenticated identity.
    func showLoggedOut() {
        currentUserId = nil
        currentUserRole = nil
        sessionState = .loggedOut
    }
}

/// Represents the supported authenticated roles in the app.
enum AppUserRole: String, CaseIterable, Identifiable, Codable, Hashable,
    Sendable
{
    case tenant
    case landlord

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

/// Describes the root-level session state that drives app navigation.
enum AppSessionState: String {
    case loading
    case loggedOut
    case guest
    case tenant
    case landlord
}
