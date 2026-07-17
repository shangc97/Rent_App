//
//  RentalRequestStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-05.
//

import Foundation
import Observation

/// Coordinates tenant and landlord request actions while keeping request state in sync for the UI.
@MainActor
@Observable
final class RentalRequestStore {
    /// Defines validation errors surfaced when a user attempts a request action they do not own.
    private enum RentalRequestStoreError: LocalizedError {
        case tenantCanOnlySubmitOwnRequest
        case tenantAlreadyHasSubmittedRequestForProperty
        case tenantCanOnlyWithdrawOwnSubmittedRequest
        case landlordCanOnlyApproveOwnSubmittedRequest
        case landlordCanOnlyDenyOwnSubmittedRequest

        var errorDescription: String? {
            switch self {
            case .tenantCanOnlySubmitOwnRequest:
                "A tenant can only submit a new request for their own account."
            case .tenantAlreadyHasSubmittedRequestForProperty:
                "You already have a pending request for this property."
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

    /// Loads all requests received by the specified landlord.
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

    /// Loads all requests submitted by the specified tenant.
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

    /// Checks whether the tenant already has a pending request for the given
    /// property before opening the final submission confirmation.
    func tenantHasSubmittedRentalRequest(
        propertyId: String,
        tenantId: String
    ) async -> Bool? {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            return try await hasSubmittedRentalRequest(
                propertyId: propertyId,
                tenantId: tenantId
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// Validates and submits a new rental request for the active tenant.
    func submitRentalRequest(
        _ rentalRequest: RentalRequest,
        tenantId: String
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            guard rentalRequest.tenantId == tenantId,
                rentalRequest.status == .submitted
            else {
                throw RentalRequestStoreError.tenantCanOnlySubmitOwnRequest
            }

            let alreadyHasSubmittedRequest = try await hasSubmittedRentalRequest(
                propertyId: rentalRequest.propertyId,
                tenantId: tenantId
            )

            guard !alreadyHasSubmittedRequest else {
                throw RentalRequestStoreError
                    .tenantAlreadyHasSubmittedRequestForProperty
            }

            try await rentalRequestRepository.createRentalRequest(rentalRequest)
            rentalRequests.insert(rentalRequest, at: 0)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        return false
    }

    /// Marks the tenant's submitted request as withdrawn.
    @discardableResult
    func withdrawRentalRequest(
        _ rentalRequest: RentalRequest,
        tenantId: String
    ) async -> Bool {
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
                requestId: rentalRequest.requestId,
                message: rentalRequest.message
            )

            var updatedRentalRequest = rentalRequest
            updatedRentalRequest.status = .withdrawn
            replaceOrInsertRentalRequest(updatedRentalRequest)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        return false
    }

    /// Approves a submitted request that belongs to the active landlord.
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

    /// Rejects a submitted request that belongs to the active landlord.
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

    /// Clears the locally cached request list.
    func clearRentalRequests() {
        rentalRequests = []
        errorMessage = nil
    }

    /// Mirrors a property-status change by locally withdrawing any still-submitted
    /// requests for that property after the persistence layer succeeds.
    func markSubmittedRequestsAsWithdrawn(for propertyId: String) {
        rentalRequests = rentalRequests.map { rentalRequest in
            guard
                rentalRequest.propertyId == propertyId,
                rentalRequest.status == .submitted
            else {
                return rentalRequest
            }

            var updatedRentalRequest = rentalRequest
            updatedRentalRequest.status = .withdrawn
            return updatedRentalRequest
        }
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

    private func hasSubmittedRentalRequest(
        propertyId: String,
        tenantId: String
    ) async throws -> Bool {
        let tenantRentalRequests = try await rentalRequestRepository
            .fetchTenantRentalRequests(tenantId: tenantId)

        return tenantRentalRequests.contains { rentalRequest in
            rentalRequest.propertyId == propertyId
                && rentalRequest.status == .submitted
        }
    }
}
