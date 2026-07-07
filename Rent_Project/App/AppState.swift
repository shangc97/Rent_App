//
//  AppState.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import Foundation
import Observation

@Observable
final class AppState {
    var sessionState: AppSessionState = .loading
    var currentUserId: String?
    var currentUserRole: AppUserRole?

    func bootstrapIfNeeded() {
        guard sessionState == .loading else { return }
        sessionState = .loggedOut
    }

    func continueAsGuest() {
        currentUserId = nil
        currentUserRole = nil
        sessionState = .guest
    }

    func signIn(as role: AppUserRole) {
        currentUserRole = role
        currentUserId = "demo-\(role.rawValue)"
        sessionState = role == .tenant ? .tenant : .landlord
    }

    func logout() {
        currentUserId = nil
        currentUserRole = nil
        sessionState = .loggedOut
    }
}

