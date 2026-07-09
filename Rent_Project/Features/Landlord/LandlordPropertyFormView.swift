//
//  LandlordPropertyFormView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Captures the editable property fields used by landlord add and edit flows.
struct LandlordPropertyDraft {
    var title = ""
    var description = ""
    var streetAddress = ""
    var city = ""
    var province = "ON"
    var postalCode = ""
    var monthlyRentText = ""
    var bedroomCount = 1
    var denCount = 0
    var bathroomCount = 1
    var parkingSpaceCount = 0
    var status: PropertyStatus = .listed
    var imageURL = ""

    /// Seeds the draft from an existing property when editing a listing.
    init(property: Property? = nil) {
        guard let property else { return }

        title = property.title
        description = property.description
        streetAddress = property.address.streetAddress
        city = property.address.city
        province = property.address.province
        postalCode = property.address.postalCode
        monthlyRentText = "\(property.monthlyRent)"
        bedroomCount = property.layout.bedroomCount
        denCount = property.layout.denCount
        bathroomCount = property.layout.bathroomCount
        parkingSpaceCount = property.parkingSpaceCount
        status = property.status
        imageURL = property.imageURL
    }

    /// Builds a validated property model from the current form fields.
    func buildProperty(propertyId: String, landlordId: String) -> Property? {
        guard
            let monthlyRent = Int(
                monthlyRentText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            ),
            monthlyRent > 0
        else {
            return nil
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStreetAddress = streetAddress.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProvince = province.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedPostalCode = postalCode.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard
            !trimmedTitle.isEmpty,
            !trimmedStreetAddress.isEmpty,
            !trimmedCity.isEmpty,
            !trimmedProvince.isEmpty,
            !trimmedPostalCode.isEmpty
        else {
            return nil
        }

        return Property(
            propertyId: propertyId,
            landlordId: landlordId,
            title: trimmedTitle,
            description: description.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            address: PropertyAddress(
                streetAddress: trimmedStreetAddress,
                city: trimmedCity,
                province: trimmedProvince,
                postalCode: trimmedPostalCode.uppercased()
            ),
            monthlyRent: monthlyRent,
            layout: PropertyLayout(
                bedroomCount: bedroomCount,
                denCount: denCount,
                bathroomCount: bathroomCount
            ),
            parkingSpaceCount: parkingSpaceCount,
            status: status,
            imageURL: imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

/// Renders the shared landlord property form fields and inline persistence errors.
struct LandlordPropertyFormView: View {
    @Binding var draft: LandlordPropertyDraft

    let errorMessage: String?

    var body: some View {
        Form {
            Section("Listing Details") {
                TextField("Property Title", text: $draft.title)
                TextField("Description", text: $draft.description, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Monthly Rent (CAD)", text: $draft.monthlyRentText)
                    .keyboardType(.numberPad)
            }

            Section("Address") {
                TextField("Street Address", text: $draft.streetAddress)
                TextField("City", text: $draft.city)
                TextField("Province", text: $draft.province)
                TextField("Postal Code", text: $draft.postalCode)
                    .textInputAutocapitalization(.characters)
            }

            Section("Layout") {
                Stepper(
                    "Bedrooms: \(draft.bedroomCount)",
                    value: $draft.bedroomCount,
                    in: 0...10
                )
                Stepper(
                    "Dens: \(draft.denCount)",
                    value: $draft.denCount,
                    in: 0...5
                )
                Stepper(
                    "Bathrooms: \(draft.bathroomCount)",
                    value: $draft.bathroomCount,
                    in: 1...10
                )
                Stepper(
                    "Parking Spaces: \(draft.parkingSpaceCount)",
                    value: $draft.parkingSpaceCount,
                    in: 0...10
                )
            }

            Section("Publishing") {
                Picker("Status", selection: $draft.status) {
                    ForEach(PropertyStatus.allCases, id: \.self) { propertyStatus in
                        Text(propertyStatus.displayName)
                            .tag(propertyStatus)
                    }
                }

                TextField("Image URL (Optional)", text: $draft.imageURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }

            if let errorMessage, !errorMessage.isEmpty {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
