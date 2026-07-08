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
        FirebaseApp.configure()

        return true
    }
}

@main
struct Rent_ProjectApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var appState = AppState()
    @State private var propertyStore = PropertyStore()
    @State private var rentalRequestStore = RentalRequestStore()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(appState)
        .environment(propertyStore)
        .environment(rentalRequestStore)
    }
}
