//
//  UserProfileRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import FirebaseFirestore
import Foundation

/// Persists and loads user profile documents from the Firestore `users` collection.
final class UserProfileRepository {
    private let COLLECTION_USER = "users"

    private var database: Firestore {
        Firestore.firestore()
    }

    /// Creates or overwrites the Firestore document for the supplied user profile.
    func createUserProfile(_ userProfile: UserProfile) async throws {
        try await database
            .collection(COLLECTION_USER)
            .document(userProfile.userId)
            .setData(firestoreData(for: userProfile))
    }

    /// Fetches a single user profile document by user id.
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        let document =
            try await database
            .collection(COLLECTION_USER)
            .document(userId)
            .getDocument()

        guard document.exists else { return nil }
        guard let data = document.data() else {
            print(
                "Could not read user profile document: \(document.documentID)"
            )
            return nil
        }

        return userProfile(from: data, userId: document.documentID)
    }

    /// Updates the stored fields for an existing user profile document.
    func updateUserProfile(_ userProfile: UserProfile) async throws {
        try await database
            .collection(COLLECTION_USER)
            .document(userProfile.userId)
            .updateData(firestoreData(for: userProfile))
    }

    private func userProfile(
        from data: [String: Any],
        userId: String
    ) -> UserProfile? {
        guard
            let email = data["email"] as? String,
            let fullName = data["fullName"] as? String,
            let rawRole = data["role"] as? String,
            let role = AppUserRole(rawValue: rawRole),
            let phoneNumber = data["phoneNumber"] as? String
        else {
            print("Could not read user profile document: \(userId)")
            return nil
        }

        return UserProfile(
            userId: userId,
            email: email,
            fullName: fullName,
            role: role,
            phoneNumber: phoneNumber
        )
    }

    private func firestoreData(for userProfile: UserProfile) -> [String: Any] {
        [
            "userId": userProfile.userId,
            "email": userProfile.email,
            "fullName": userProfile.fullName,
            "role": userProfile.role.rawValue,
            "phoneNumber": userProfile.phoneNumber,
        ]
    }
}
