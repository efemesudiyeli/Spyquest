//
//  LocationsView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct LocationsView: View {
    @ObservedObject var viewModel: GameViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
    
        VStack {
            if viewModel.isGameStarted {
                Label("\(viewModel.formattedTimeInterval(viewModel.timeRemaining))", systemImage: "hourglass")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical)
                    .contentTransition(.numericText())

            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Location.locationData) { location in
                        VStack {
                            Text(location.name)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    NavigationStack {
        LocationsView(viewModel: GameViewModel(isSampleData: true))
    }
}
