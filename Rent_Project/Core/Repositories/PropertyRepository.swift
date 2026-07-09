//
//  PropertyRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import FirebaseFirestore
import Foundation

/// Persists property listings and runs Firestore queries used by browse and landlord flows.
final class PropertyRepository {
    private let COLLECTION_PROPERTY = "properties"

    private var database: Firestore {
        Firestore.firestore()
    }

    /// Fetches every property document from Firestore.
    func fetchAllProperties() async throws -> [Property] {
        let snapshot = try await database
            .collection(COLLECTION_PROPERTY)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            property(from: document)
        }
    }

    /// Fetches only properties that are currently listed.
    func fetchListedProperties() async throws -> [Property] {
        let snapshot = try await database
            .collection(COLLECTION_PROPERTY)
            .whereField(
                "status",
                isEqualTo: PropertyStatus.listed.rawValue
            )
            .getDocuments()

        return snapshot.documents.compactMap { document in
            property(from: document)
        }
    }

    /// Fetches all properties owned by the specified landlord.
    func fetchLandlordProperties(landlordId: String) async throws -> [Property] {
        let snapshot = try await database
            .collection(COLLECTION_PROPERTY)
            .whereField(
                "landlordId",
                isEqualTo: landlordId
            )
            .getDocuments()

        return snapshot.documents.compactMap { document in
            property(from: document)
        }
    }

    /// Writes a new property document using the model's existing id.
    func addProperty(_ property: Property) async throws {
        try await database
            .collection(COLLECTION_PROPERTY)
            .document(property.propertyId)
            .setData(firestoreData(for: property))
    }

    /// Updates the Firestore document for an existing property.
    func updateProperty(propertyId: String, property: Property) async throws {
        try await database
            .collection(COLLECTION_PROPERTY)
            .document(propertyId)
            .updateData(firestoreData(for: property))
    }

    /// Deletes a property document from Firestore.
    func deleteProperty(propertyId: String) async throws {
        try await database
            .collection(COLLECTION_PROPERTY)
            .document(propertyId)
            .delete()
    }

    private func property(from document: QueryDocumentSnapshot) -> Property? {
        let data = document.data()

        guard
            let landlordId = data["landlordId"] as? String,
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let address = data["address"] as? [String: Any],
            let streetAddress = address["streetAddress"] as? String,
            let city = address["city"] as? String,
            let province = address["province"] as? String,
            let postalCode = address["postalCode"] as? String,
            let monthlyRent = data["monthlyRent"] as? Int,
            let layout = data["layout"] as? [String: Any],
            let bedroomCount = layout["bedroomCount"] as? Int,
            let denCount = layout["denCount"] as? Int,
            let bathroomCount = layout["bathroomCount"] as? Int,
            let parkingSpaceCount = data["parkingSpaceCount"] as? Int,
            let rawStatus = data["status"] as? String,
            let status = PropertyStatus(rawValue: rawStatus),
            let imageURL = data["imageURL"] as? String
        else {
            print("Could not read property document: \(document.documentID)")
            return nil
        }

        return Property(
            propertyId: document.documentID,
            landlordId: landlordId,
            title: title,
            description: description,
            address: PropertyAddress(
                streetAddress: streetAddress,
                city: city,
                province: province,
                postalCode: postalCode
            ),
            monthlyRent: monthlyRent,
            layout: PropertyLayout(
                bedroomCount: bedroomCount,
                denCount: denCount,
                bathroomCount: bathroomCount
            ),
            parkingSpaceCount: parkingSpaceCount,
            status: status,
            imageURL: imageURL
        )
    }

    private func firestoreData(for property: Property) -> [String: Any] {
        [
            "propertyId": property.propertyId,
            "landlordId": property.landlordId,
            "title": property.title,
            "description": property.description,
            "address": [
                "streetAddress": property.address.streetAddress,
                "city": property.address.city,
                "province": property.address.province,
                "postalCode": property.address.postalCode,
            ],
            "monthlyRent": property.monthlyRent,
            "layout": [
                "bedroomCount": property.layout.bedroomCount,
                "denCount": property.layout.denCount,
                "bathroomCount": property.layout.bathroomCount,
            ],
            "parkingSpaceCount": property.parkingSpaceCount,
            "status": property.status.rawValue,
            "imageURL": property.imageURL,
        ]
    }
}
