//
//  SwiftUIView.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/12/26.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(spacing: 16) {
            Button("View Collection") {
                // TODO: Add Button Action
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .clipShape(.capsule)
            
            Button("Scan Barcode") {
                // TODO: Add Scan Action
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(.capsule)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    SwiftUIView()
}
