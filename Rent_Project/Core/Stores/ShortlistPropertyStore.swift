//
//  ShortlistPropertyStore.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-08.
//

import Foundation
import Observation

/// Manages the tenant shortlist collection in memory and syncs changes through `ShortlistPropertyRepository`.
@MainActor
@Observable
final class ShortlistPropertyStore {
    var shortlistProperties: [ShortlistProperty] = []
    var isLoading = false
    var errorMessage: String?

    private let shortlistPropertyRepository: ShortlistPropertyRepository

    init() {
        self.shortlistPropertyRepository = ShortlistPropertyRepository()
    }

    init(shortlistPropertyRepository: ShortlistPropertyRepository) {
        self.shortlistPropertyRepository = shortlistPropertyRepository
    }

    /// Loads the shortlist entries for a tenant.
    func loadTenantShortlist(tenantId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            shortlistProperties = try await shortlistPropertyRepository
                .fetchTenantShortlistProperties(tenantId: tenantId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Adds a property to the tenant's shortlist when it is not already saved.
    func addPropertyToShortlist(
        propertyId: String,
        tenantId: String
    ) async {
        errorMessage = nil

        guard !isPropertyShortlisted(propertyId: propertyId, tenantId: tenantId)
        else {
            return
        }

        isLoading = true

        let shortlistProperty = ShortlistProperty(
            shortlistPropertyId: shortlistPropertyId(
                tenantId: tenantId,
                propertyId: propertyId
            ),
            tenantId: tenantId,
            propertyId: propertyId
        )

        do {
            try await shortlistPropertyRepository.createShortlistProperty(
                shortlistProperty
            )
            shortlistProperties.insert(shortlistProperty, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Removes an existing shortlisted property for the tenant.
    func removePropertyFromShortlist(
        propertyId: String,
        tenantId: String
    ) async {
        errorMessage = nil

        guard
            let shortlistProperty = shortlistProperties.first(where: {
                $0.propertyId == propertyId && $0.tenantId == tenantId
            })
        else {
            return
        }

        isLoading = true

        do {
            try await shortlistPropertyRepository.deleteShortlistProperty(
                shortlistPropertyId: shortlistProperty.shortlistPropertyId
            )
            shortlistProperties.removeAll {
                $0.shortlistPropertyId == shortlistProperty.shortlistPropertyId
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Returns whether the tenant has already shortlisted the supplied property.
    func isPropertyShortlisted(
        propertyId: String,
        tenantId: String
    ) -> Bool {
        shortlistProperties.contains {
            $0.propertyId == propertyId && $0.tenantId == tenantId
        }
    }

    /// Clears the locally cached shortlist collection.
    func clearShortlist() {
        shortlistProperties = []
        errorMessage = nil
    }

    private func shortlistPropertyId(
        tenantId: String,
        propertyId: String
    ) -> String {
        "\(tenantId)_\(propertyId)"
    }
}
