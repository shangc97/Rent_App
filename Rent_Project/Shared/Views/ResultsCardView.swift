//
//  ResultsCardView.swift
//  Rent_Project
//
//  Created by Codex on 2026-07-09.
//

import SwiftUI

/// Wraps row content in the shared rounded card style used by list-like result screens.
struct ResultsCardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    /// Displays the supplied content inside the shared card shell.
    var body: some View {
        content()
            .padding(14)
            .background(cardBackground)
            .overlay(cardBorder)
    }

    /// Provides the card background used for each result row.
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground))
    }

    /// Provides the border used for each result row.
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }
}
