//
//  PropertyStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
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

    /// Loads only properties whose status is currently listed.
    func loadListedProperties() async {
        isLoading = true
        errorMessage = nil

        do {
            properties = try await propertyRepository.fetchListedProperties()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Loads all properties that belong to the given landlord.
    func loadLandlordProperties(landlordId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            properties = try await propertyRepository.fetchLandlordProperties(
                landlordId: landlordId
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Persists a new property and inserts it into local state on success.
    func addProperty(_ property: Property) async {
        isLoading = true
        errorMessage = nil

        do {
            try await propertyRepository.addProperty(property)
            properties.insert(property, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Persists updates for an existing property and refreshes the matching local item.
    func updateProperty(propertyId: String, property: Property) async {
        isLoading = true
        errorMessage = nil

        do {
            try await propertyRepository.updateProperty(
                propertyId: propertyId,
                property: property
            )

            if let index = properties.firstIndex(where: {
                $0.propertyId == propertyId
            }) {
                properties[index] = property
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
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
