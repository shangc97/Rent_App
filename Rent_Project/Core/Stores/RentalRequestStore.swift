//
//  RentalRequestStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import Foundation
import Observation

@MainActor
@Observable
final class RentalRequestStore {
    var rentalRequests: [RentalRequest] = []
    var isLoading = false
    var errorMessage: String?

    private let rentalRequestRepository: RentalRequestRepository

    init() {
        self.rentalRequestRepository = RentalRequestRepository()
    }

    init(rentalRequestRepository: RentalRequestRepository) {
        self.rentalRequestRepository = rentalRequestRepository
    }

    func loadAllRentalRequests() async {
        isLoading = true
        errorMessage = nil

        do {
            rentalRequests = try await rentalRequestRepository.fetchAllRentalRequests()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadLandlordRentalRequests(landlordId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            rentalRequests = try await rentalRequestRepository
                .fetchLandlordRentalRequests(landlordId: landlordId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadTenantRentalRequests(tenantId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            rentalRequests = try await rentalRequestRepository
                .fetchTenantRentalRequests(tenantId: tenantId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addRentalRequest(_ rentalRequest: RentalRequest) async {
        isLoading = true
        errorMessage = nil

        do {
            try await rentalRequestRepository.addRentalRequest(rentalRequest)
            rentalRequests.insert(rentalRequest, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateRentalRequest(
        requestId: String,
        rentalRequest: RentalRequest
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            try await rentalRequestRepository.updateRentalRequest(
                requestId: requestId,
                rentalRequest: rentalRequest
            )

            if let index = rentalRequests.firstIndex(where: {
                $0.requestId == requestId
            }) {
                rentalRequests[index] = rentalRequest
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteRentalRequest(requestId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await rentalRequestRepository.deleteRentalRequest(
                requestId: requestId
            )
            rentalRequests.removeAll { $0.requestId == requestId }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
