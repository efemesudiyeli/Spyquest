//
//  LocationsView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct LocationsView<ViewModel: ObservableObject>: View {
    @ObservedObject var viewModel: ViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Location.locationData) { location in
                        LocationCard(location: location)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(NSLocalizedString("Locations", comment: ""))
        .navigationBarTitleDisplayMode(.automatic)
    }
}

struct LocationCard: View {
    let location: Location
    
    var body: some View {
        VStack(spacing: 12) {
            Text(location.name)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("\(location.roles.count) \(NSLocalizedString("roles", comment: ""))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        LocationsView(viewModel: MultiplayerGameViewModel())
    }
}
