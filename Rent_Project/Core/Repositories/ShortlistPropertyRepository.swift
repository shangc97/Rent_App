//
//  ShortlistPropertyRepository.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-08.
//

import FirebaseFirestore
import Foundation

/// Persists tenant shortlist entries in Firestore.
final class ShortlistPropertyRepository {
    private let COLLECTION_SHORTLIST_PROPERTY = "shortlistProperties"

    private var database: Firestore {
        Firestore.firestore()
    }

    /// Fetches all shortlist entries owned by a tenant.
    func fetchTenantShortlistProperties(
        tenantId: String
    ) async throws -> [ShortlistProperty] {
        let snapshot = try await database
            .collection(COLLECTION_SHORTLIST_PROPERTY)
            .whereField(
                "tenantId",
                isEqualTo: tenantId
            )
            .getDocuments()

        return snapshot.documents.compactMap { document in
            shortlistProperty(from: document)
        }
    }

    /// Creates a shortlist entry document for the given tenant and property pair.
    func createShortlistProperty(
        _ shortlistProperty: ShortlistProperty
    ) async throws {
        try await database
            .collection(COLLECTION_SHORTLIST_PROPERTY)
            .document(shortlistProperty.shortlistPropertyId)
            .setData(firestoreData(for: shortlistProperty))
    }

    /// Deletes a shortlist entry document.
    func deleteShortlistProperty(shortlistPropertyId: String) async throws {
        try await database
            .collection(COLLECTION_SHORTLIST_PROPERTY)
            .document(shortlistPropertyId)
            .delete()
    }

    private func shortlistProperty(
        from document: QueryDocumentSnapshot
    ) -> ShortlistProperty? {
        let data = document.data()

        guard
            let tenantId = data["tenantId"] as? String,
            let propertyId = data["propertyId"] as? String
        else {
            print(
                "Could not read shortlist property document: \(document.documentID)"
            )
            return nil
        }

        return ShortlistProperty(
            shortlistPropertyId: document.documentID,
            tenantId: tenantId,
            propertyId: propertyId
        )
    }

    private func firestoreData(
        for shortlistProperty: ShortlistProperty
    ) -> [String: Any] {
        [
            "shortlistPropertyId": shortlistProperty.shortlistPropertyId,
            "tenantId": shortlistProperty.tenantId,
            "propertyId": shortlistProperty.propertyId,
        ]
    }
}
