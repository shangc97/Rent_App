//
//  AppState+Preview.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import Foundation

extension AppState {
    static func preview(
        sessionState: AppSessionState,
        currentUserRole: AppUserRole? = nil,
        currentUserId: String? = nil
    ) -> AppState {
        let appState = AppState()
        appState.sessionState = sessionState
        appState.currentUserRole = currentUserRole
        appState.currentUserId = currentUserId
        return appState
    }
}
