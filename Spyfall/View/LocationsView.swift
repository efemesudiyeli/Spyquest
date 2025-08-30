//
//  LocationsView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct LocationsView<ViewModel: ObservableObject>: View {
    @ObservedObject var viewModel: ViewModel
    let locationSet: LocationSets
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(locationSet.locations.enumerated()), id: \.element.id) { index, location in
                        LocationCard(location: location)
                            
                            .background(
                                (index % 2 == 0) ? Color(
                                    .tertiarySystemGroupedBackground
                                ) : Color(.secondarySystemGroupedBackground)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                    }
                }
                .padding()
            }
        }
        .navigationTitle(NSLocalizedString("Locations", comment: ""))
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("Done", comment: "")) {
                    dismiss()
                }
            }
        }
    }
}

struct LocationCard: View {
    let location: Location
    
    var body: some View {
        Text(location.name)
            .font(.subheadline)
            .fontWeight(.medium)
            .fontDesign(.monospaced)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        LocationsView(viewModel: MultiplayerGameViewModel(), locationSet: .spyfallOne)
    }
}
