//
//  RentalRequestRepository.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import FirebaseFirestore
import Foundation

final class RentalRequestRepository {
    private let database = Firestore.firestore()
    private let COLLECTION_RENTAL_REQUEST = "rentalRequests"

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

    func createRentalRequest(_ rentalRequest: RentalRequest) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(rentalRequest.requestId)
            .setData(firestoreData(for: rentalRequest))
    }

    func withdrawRentalRequest(requestId: String) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(requestId)
            .updateData([
                "status": RentalRequestStatus.withdrawn.rawValue
            ])
    }

    func approveRentalRequest(requestId: String) async throws {
        try await database
            .collection(COLLECTION_RENTAL_REQUEST)
            .document(requestId)
            .updateData([
                "status": RentalRequestStatus.approved.rawValue
            ])
    }

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
            print("Could not read rental request document: \(document.documentID)")
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
