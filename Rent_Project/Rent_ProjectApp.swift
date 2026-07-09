//
//  Rent_ProjectApp.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        return true
    }
}

@main
struct Rent_ProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var appState = AppState()
    @State private var authStore = AuthStore()
    @State private var propertyStore = PropertyStore()
    @State private var rentalRequestStore = RentalRequestStore()
    @State private var shortlistPropertyStore = ShortlistPropertyStore()
    @State private var userProfileStore = UserProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(appState)
        .environment(authStore)
        .environment(propertyStore)
        .environment(rentalRequestStore)
        .environment(shortlistPropertyStore)
        .environment(userProfileStore)
    }
}
