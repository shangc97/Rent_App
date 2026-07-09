//
//  RentalRequestRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-05.
//

import FirebaseFirestore
import Foundation

/// Persists rental request documents and request status changes in Firestore.
final class RentalRequestRepository {
    private let COLLECTION_RENTAL_REQUEST = "rentalRequests"

    private var database: Firestore {
        Firestore.firestore()
    }

    /// Fetches all rental requests received by a landlord.
    func fetchLandlordRentalRequests(landlordId: String) async throws -> [RentalRequest] {
        let snapshot = try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .whereField(
                "landlordId",
                isEqualTo: landlordId
            )
            .getDocuments()

        return snapshot.documents.compactMap { document in
            rentalRequest(from: document)
        }
    }

    /// Fetches all rental requests submitted by a tenant.
    func fetchTenantRentalRequests(tenantId: String) async throws -> [RentalRequest] {
        let snapshot = try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .whereField(
                "tenantId",
                isEqualTo: tenantId
            )
            .getDocuments()

        return snapshot.documents.compactMap { document in
            rentalRequest(from: document)
        }
    }

    /// Creates a new rental request document.
    func createRentalRequest(_ rentalRequest: RentalRequest) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(rentalRequest.requestId)
            .setData(firestoreData(for: rentalRequest))
    }

    /// Marks a submitted request as withdrawn and stores the tenant's withdrawal message.
    func withdrawRentalRequest(
        requestId: String,
        message: String
    ) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(requestId)
            .updateData([
                "status": RentalRequestStatus.withdrawn.rawValue,
                "message": message,
            ])
    }

    /// Marks a request as approved.
    func approveRentalRequest(requestId: String) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(requestId)
            .updateData([
                "status": RentalRequestStatus.approved.rawValue
            ])
    }

    /// Marks a request as rejected.
    func denyRentalRequest(requestId: String) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(requestId)
            .updateData([
                "status": RentalRequestStatus.rejected.rawValue
            ])
    }

    private func rentalRequest(
        from document: QueryDocumentSnapshot
    ) -> RentalRequest? {
        let data = document.data()

        guard
            let propertyId = data["propertyId"] as? String,
            let tenantId = data["tenantId"] as? String,
            let landlordId = data["landlordId"] as? String,
            let rawStatus = data["status"] as? String,
            let status = RentalRequestStatus(rawValue: rawStatus),
            let message = data["message"] as? String
        else {
            return nil
        }

        return RentalRequest(
            requestId: document.documentID,
            propertyId: propertyId,
            tenantId: tenantId,
            landlordId: landlordId,
            status: status,
            message: message
        )
    }

    private func firestoreData(for rentalRequest: RentalRequest) -> [String: Any] {
        [
            "requestId": rentalRequest.requestId,
            "propertyId": rentalRequest.propertyId,
            "tenantId": rentalRequest.tenantId,
            "landlordId": rentalRequest.landlordId,
            "status": rentalRequest.status.rawValue,
            "message": rentalRequest.message,
        ]
    }
}
