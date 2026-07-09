//
//  LandlordAddPropertyView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Presents the landlord form used to create a new listing or edit an
/// existing property before saving it back to the shared store.
struct LandlordAddPropertyView: View {
    @Environment(\.dismiss) private var dismiss

    let landlordId: String
    let propertyToEdit: Property?
    let onSave: (Property) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var streetAddress = ""
    @State private var city = ""
    @State private var province = "ON"
    @State private var postalCode = ""
    @State private var monthlyRentText = ""
    @State private var bedroomCount = 1
    @State private var denCount = 0
    @State private var bathroomCount = 1
    @State private var parkingSpaceCount = 0
    @State private var status: PropertyStatus = .listed
    @State private var imageURL = ""
    @State private var isShowingSaveConfirmation = false

    /// Seeds the form with either empty values for a new listing or the
    /// current property values for edit mode.
    init(
        landlordId: String,
        propertyToEdit: Property? = nil,
        onSave: @escaping (Property) -> Void
    ) {
        self.landlordId = landlordId
        self.propertyToEdit = propertyToEdit
        self.onSave = onSave
        _title = State(initialValue: propertyToEdit?.title ?? "")
        _description = State(initialValue: propertyToEdit?.description ?? "")
        _streetAddress = State(
            initialValue: propertyToEdit?.address.streetAddress ?? ""
        )
        _city = State(initialValue: propertyToEdit?.address.city ?? "")
        _province = State(initialValue: propertyToEdit?.address.province ?? "ON")
        _postalCode = State(
            initialValue: propertyToEdit?.address.postalCode ?? ""
        )
        _monthlyRentText = State(
            initialValue: propertyToEdit.map { "\($0.monthlyRent)" } ?? ""
        )
        _bedroomCount = State(
            initialValue: propertyToEdit?.layout.bedroomCount ?? 1
        )
        _denCount = State(initialValue: propertyToEdit?.layout.denCount ?? 0)
        _bathroomCount = State(
            initialValue: propertyToEdit?.layout.bathroomCount ?? 1
        )
        _parkingSpaceCount = State(
            initialValue: propertyToEdit?.parkingSpaceCount ?? 0
        )
        _status = State(initialValue: propertyToEdit?.status ?? .listed)
        _imageURL = State(initialValue: propertyToEdit?.imageURL ?? "")
    }

    /// Renders the landlord property form along with the save confirmation flow.
    var body: some View {
        Form {
            Section("Listing Details") {
                TextField("Property Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Monthly Rent (CAD)", text: $monthlyRentText)
                    .keyboardType(.numberPad)
            }

            Section("Address") {
                TextField("Street Address", text: $streetAddress)
                TextField("City", text: $city)
                TextField("Province", text: $province)
                TextField("Postal Code", text: $postalCode)
                    .textInputAutocapitalization(.characters)
            }

            Section("Layout") {
                Stepper("Bedrooms: \(bedroomCount)", value: $bedroomCount, in: 0...10)
                Stepper("Dens: \(denCount)", value: $denCount, in: 0...5)
                Stepper("Bathrooms: \(bathroomCount)", value: $bathroomCount, in: 1...10)
                Stepper("Parking Spaces: \(parkingSpaceCount)", value: $parkingSpaceCount, in: 0...10)
            }

            Section("Publishing") {
                Picker("Status", selection: $status) {
                    ForEach(PropertyStatus.allCases, id: \.self) { propertyStatus in
                        Text(propertyStatus.displayName)
                            .tag(propertyStatus)
                    }
                }

                TextField("Image URL (Optional)", text: $imageURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            saveConfirmationTitle,
            isPresented: $isShowingSaveConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button(saveButtonTitle) {
                confirmSave()
            }
        } message: {
            Text(saveConfirmationMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(saveButtonTitle) {
                    isShowingSaveConfirmation = true
                }
                .disabled(newProperty == nil)
            }
        }
    }

    /// Returns the navigation title for either add or edit mode.
    private var navigationTitle: String {
        propertyToEdit == nil ? "Add Property" : "Edit Property"
    }

    /// Returns the primary save action title for the current form mode.
    private var saveButtonTitle: String {
        propertyToEdit == nil ? "Save" : "Update"
    }

    /// Returns the confirmation alert title shown before persisting the form.
    private var saveConfirmationTitle: String {
        propertyToEdit == nil ? "Save Property?" : "Update Property?"
    }

    /// Returns the confirmation alert message for the current save action.
    private var saveConfirmationMessage: String {
        propertyToEdit == nil
            ? "Please confirm that you want to create this property listing."
            : "Please confirm that you want to save these property detail changes."
    }

    /// Builds a validated property model from the current form state when all
    /// required fields and rent input are valid.
    private var newProperty: Property? {
        guard
            let monthlyRent = Int(monthlyRentText.trimmingCharacters(in: .whitespacesAndNewlines)),
            monthlyRent > 0
        else {
            return nil
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStreetAddress = streetAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProvince = province.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPostalCode = postalCode.trimmingCharacters(in: .whitespacesAndNewlines)

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
            propertyId: propertyToEdit?.propertyId
                ?? "property-\(UUID().uuidString.lowercased())",
            landlordId: landlordId,
            title: trimmedTitle,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
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

    /// Sends the validated property back to the parent flow and closes the
    /// form after the user confirms the save action.
    private func confirmSave() {
        guard let property = newProperty else { return }
        onSave(property)
        dismiss()
    }
}
