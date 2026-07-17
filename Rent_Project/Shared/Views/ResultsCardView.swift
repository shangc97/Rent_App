//
//  ResultsCardView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-09.
//

import SwiftUI

/// Wraps row content in the shared rounded card style used by list-like result screens.
struct ResultsCardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .background(cardBackground)
            .overlay(cardBorder)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }
}
