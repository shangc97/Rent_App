//
//  Rent_ProjectApp.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

@main
struct Rent_ProjectApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(appState)
    }
}
