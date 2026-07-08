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

    func continueAsGuest() {
        currentUserId = nil
        currentUserRole = nil
        sessionState = .guest
    }

    func setAuthenticatedSession(userId: String, role: AppUserRole) {
        currentUserId = userId
        currentUserRole = role
        sessionState = role == .tenant ? .tenant : .landlord
    }

    func showLoggedOut() {
        currentUserId = nil
        currentUserRole = nil
        sessionState = .loggedOut
    }
}
