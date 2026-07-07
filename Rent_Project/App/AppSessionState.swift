//
//  AppSessionState.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import Foundation

enum AppUserRole: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case tenant
    case landlord

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

enum AppSessionState: String {
    case loading
    case loggedOut
    case guest
    case tenant
    case landlord
}
