//
//  LoadingView.swift
//  Rent_Project
//
//  Created by Chuhan Shang on 2026-07-06.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text("Preparing app foundation...")
                .font(.headline)

            Text(
                "Checking the root flow before sending the user into auth, guest, tenant, or landlord mode."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

//#Preview {
//    LoadingView()
//}
