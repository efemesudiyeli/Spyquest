//
//  SettingsView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 29.07.2024.
//

import SwiftUI

struct ProPurchaseView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        List {
            Section {
                if !viewModel.isAdsRemoved {
                    if viewModel.product != nil {
                        Button {
                            viewModel.purchaseProduct()
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                Text("Remove Ads")
                            }
                        }.disabled(viewModel.isPurchasing)
                    } else {
                        Button {
                            viewModel.purchaseProduct()
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Remove Ads")
                            }
                        }.disabled(true)
                    }
                    
                } else {
                    HStack {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                        Text("Ads Removed")
                    }
                }
                
                Button(action: {
                    viewModel.restorePurchases()
                }, label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Restore Purchases")
                    }
                   
                })
            } header: {
                Text("Purchases")
            }
        }
        .alert("Restore Purchases", isPresented: $viewModel.showingRestoreAlert) {
            Text("OK")
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    ProPurchaseView(viewModel: GameViewModel(isSampleData: true))
}
