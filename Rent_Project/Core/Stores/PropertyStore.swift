//
//  PropertyStore.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-08.
//

import Foundation
import Observation

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
