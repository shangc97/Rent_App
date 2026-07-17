//
//  PropertyRowView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-07.
//

import SwiftUI

/// Renders a compact property summary card used by browse and search result lists.
struct PropertyRowView: View {
    let property: Property

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(property.address.streetAddress)
                    .font(.headline)

                Text("\(property.address.city), \(property.address.province)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(property.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                featureSection

                Text(property.formattedRent)
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            propertyImage
                .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    private var featureSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "bed.double.fill")
                if property.layout.hasDen {
                    Text(
                        "\(property.layout.bedroomCount)+\(property.layout.denCount)"
                    )
                } else {

                    Text("\(property.layout.bedroomCount)")
                }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Image(systemName: "bathtub.fill")
                Text("\(property.layout.bathroomCount)")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)

            if property.hasParking {
                HStack(spacing: 4) {
                    Image(systemName: "car.fill")
                    Text("\(property.parkingSpaceCount)")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var propertyImage: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                    ProgressView()
                }
            case .failure:
                imagePlaceholder
            @unknown default:
                imagePlaceholder
            }
        }
        .frame(width: 130, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
    }

    private var imagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(.secondarySystemBackground))

            Image(systemName: "photo")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var imageURL: URL? {
        guard !property.imageURL.isEmpty else { return nil }
        return URL(string: property.imageURL)
    }
}
