//
//  FixedTopScrollableResultsLayout.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-09.
//

import SwiftUI

/// Provides the shared page layout used by screens with a fixed top control and
/// a separately scrollable results container underneath.
struct FixedTopScrollableResultsLayout<
    TopContent: View,
    ResultsContent: View,
    ScrollIdentity: Hashable
>: View {
    let resultsTitle: String
    let scrollIdentity: ScrollIdentity

    @ViewBuilder let topContent: () -> TopContent
    @ViewBuilder let resultsContent: () -> ResultsContent

    /// Renders the fixed top content and the shared framed results region.
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                topContent()
                resultsSection
                    .frame(
                        minHeight: max(geometry.size.height * 0.45, 320),
                        maxHeight: .infinity
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .top
            )
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    /// Displays the titled results container and its independently scrollable content.
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(resultsTitle)
                .font(.headline)

            ScrollView {
                LazyVStack(spacing: 12) {
                    resultsContent()
                }
                .padding(16)
                .id(scrollIdentity)
            }
            .scrollIndicators(.visible)
            .background(resultsBackground)
            .overlay(resultsBorder)
        }
    }

    /// Provides the background card used behind the results scroll view.
    private var resultsBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
    }

    /// Provides the border used around the results scroll view container.
    private var resultsBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }
}
