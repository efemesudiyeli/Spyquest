//
//  CountdownView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct CountdownView: View {
    let countdown: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Text(NSLocalizedString("Get Ready!", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("\(max(countdown, 1))")
                .font(.system(size: 96, weight: .bold))
                .foregroundColor(.blue)
                .transition(.scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CountdownView(countdown: 3)
}

