//
//  PropertyRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-05.
//

import FirebaseFirestore
import Foundation

/// Persists property listings and runs Firestore queries used by browse and landlord flows.
final class PropertyRepository {
    private let COLLECTION_PROPERTY = "properties"
    private let COLLECTION_RENTAL_REQUEST = "rentalRequests"

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

    /// Writes a new property document using the model's existing id.
    func addProperty(_ property: Property) async throws {
        try await database
            .collection(COLLECTION_PROPERTY)
            .document(property.propertyId)
            .setData(firestoreData(for: property))
    }

    /// Updates the Firestore document for an existing property and optionally
    /// withdraws any still-submitted requests for that property in the same batch.
    func updateProperty(
        propertyId: String,
        property: Property,
        shouldWithdrawSubmittedRequests: Bool
    ) async throws {
        let propertyDocument = database
            .collection(COLLECTION_PROPERTY)
            .document(propertyId)

        guard shouldWithdrawSubmittedRequests else {
            try await propertyDocument.updateData(firestoreData(for: property))
            return
        }

        let submittedRequestSnapshot = try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .whereField("propertyId", isEqualTo: propertyId)
            .whereField(
                "status",
                isEqualTo: RentalRequestStatus.submitted.rawValue
            )
            .getDocuments()

        let batch = database.batch()
        batch.updateData(firestoreData(for: property), forDocument: propertyDocument)

        for document in submittedRequestSnapshot.documents {
            batch.updateData(
                ["status": RentalRequestStatus.withdrawn.rawValue],
                forDocument: document.reference
            )
        }

        try await batch.commit()
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
