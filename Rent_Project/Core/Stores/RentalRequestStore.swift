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
    private enum RentalRequestStoreError: LocalizedError {
        case tenantCanOnlySubmitOwnRequest
        case tenantCanOnlyWithdrawOwnSubmittedRequest
        case landlordCanOnlyApproveOwnSubmittedRequest
        case landlordCanOnlyDenyOwnSubmittedRequest

        var errorDescription: String? {
            switch self {
            case .tenantCanOnlySubmitOwnRequest:
                "A tenant can only submit a new request for their own account."
            case .tenantCanOnlyWithdrawOwnSubmittedRequest:
                "A tenant can only withdraw their own submitted request."
            case .landlordCanOnlyApproveOwnSubmittedRequest:
                "A landlord can only approve their own submitted request."
            case .landlordCanOnlyDenyOwnSubmittedRequest:
                "A landlord can only deny their own submitted request."
            }
        }
    }

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

    func submitRentalRequest(
        _ rentalRequest: RentalRequest,
        tenantId: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            guard rentalRequest.tenantId == tenantId,
                rentalRequest.status == .submitted
            else {
                throw RentalRequestStoreError.tenantCanOnlySubmitOwnRequest
            }

            try await rentalRequestRepository.createRentalRequest(rentalRequest)
            rentalRequests.insert(rentalRequest, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func withdrawRentalRequest(
        _ rentalRequest: RentalRequest,
        tenantId: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            guard rentalRequest.tenantId == tenantId,
                rentalRequest.status == .submitted
            else {
                throw RentalRequestStoreError
                    .tenantCanOnlyWithdrawOwnSubmittedRequest
            }

            try await rentalRequestRepository.withdrawRentalRequest(
                requestId: rentalRequest.requestId
            )

            var updatedRentalRequest = rentalRequest
            updatedRentalRequest.status = .withdrawn
            replaceOrInsertRentalRequest(updatedRentalRequest)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func approveRentalRequest(
        _ rentalRequest: RentalRequest,
        landlordId: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            guard rentalRequest.landlordId == landlordId,
                rentalRequest.status == .submitted
            else {
                throw RentalRequestStoreError
                    .landlordCanOnlyApproveOwnSubmittedRequest
            }

            try await rentalRequestRepository.approveRentalRequest(
                requestId: rentalRequest.requestId
            )

            var updatedRentalRequest = rentalRequest
            updatedRentalRequest.status = .approved
            replaceOrInsertRentalRequest(updatedRentalRequest)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func denyRentalRequest(
        _ rentalRequest: RentalRequest,
        landlordId: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            guard rentalRequest.landlordId == landlordId,
                rentalRequest.status == .submitted
            else {
                throw RentalRequestStoreError
                    .landlordCanOnlyDenyOwnSubmittedRequest
            }

            try await rentalRequestRepository.denyRentalRequest(
                requestId: rentalRequest.requestId
            )

            var updatedRentalRequest = rentalRequest
            updatedRentalRequest.status = .rejected
            replaceOrInsertRentalRequest(updatedRentalRequest)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clearRentalRequests() {
        rentalRequests = []
        errorMessage = nil
    }

    private func replaceOrInsertRentalRequest(_ rentalRequest: RentalRequest) {
        if let index = rentalRequests.firstIndex(where: {
            $0.requestId == rentalRequest.requestId
        }) {
            rentalRequests[index] = rentalRequest
        } else {
            rentalRequests.insert(rentalRequest, at: 0)
        }
    }
}
