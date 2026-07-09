//
//  PropertyStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-05.
//

import Foundation
import Observation

/// Manages the in-memory property collection and delegates persistence to `PropertyRepository`.
@MainActor
@Observable
final class PropertyStore {
    var properties: [Property] = []
    var isLoading = false
    var errorMessage: String?

    private let propertyRepository: PropertyRepository

    init() {
        self.propertyRepository = PropertyRepository()
    }

    init(propertyRepository: PropertyRepository) {
        self.propertyRepository = propertyRepository
    }

    /// Loads every property into local state.
    func loadAllProperties() async {
        isLoading = true
        errorMessage = nil

        do {
            properties = try await propertyRepository.fetchAllProperties()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Loads all properties once when the store has not been populated yet.
    func loadAllPropertiesIfNeeded() async {
        guard properties.isEmpty, !isLoading else { return }
        await loadAllProperties()
    }

    /// Persists a new property and inserts it into local state on success.
    @discardableResult
    func addProperty(_ property: Property) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await propertyRepository.addProperty(property)
            properties.insert(property, at: 0)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }

        isLoading = false
        return true
    }

    /// Persists updates for an existing property, and when the listing becomes
    /// unavailable it also withdraws any submitted requests for that property.
    @discardableResult
    func updateProperty(
        propertyId: String,
        property: Property,
        previousStatus: PropertyStatus? = nil,
        rentalRequestStore: RentalRequestStore? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let resolvedPreviousStatus =
                previousStatus
                ?? properties.first(where: { $0.propertyId == propertyId })?.status
                ?? property.status
            let shouldWithdrawSubmittedRequests =
                resolvedPreviousStatus == .listed && property.status != .listed

            try await propertyRepository.updateProperty(
                propertyId: propertyId,
                property: property,
                shouldWithdrawSubmittedRequests: shouldWithdrawSubmittedRequests
            )

            if let index = properties.firstIndex(where: {
                $0.propertyId == propertyId
            }) {
                properties[index] = property
            }

            if shouldWithdrawSubmittedRequests {
                rentalRequestStore?.markSubmittedRequestsAsWithdrawn(
                    for: propertyId
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }

        isLoading = false
        return true
    }

    /// Deletes a property from Firestore and removes it from local state.
    func deleteProperty(propertyId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await propertyRepository.deleteProperty(propertyId: propertyId)
            properties.removeAll { $0.propertyId == propertyId }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
