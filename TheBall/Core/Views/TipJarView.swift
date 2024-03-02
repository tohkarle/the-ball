//
//  TipJarView.swift
//  TheBall
//
//  Created by Toh Kar Le on 2/3/24.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    
    @StateObject var storeKit = StoreKitManager()
    
    @State private var showLoading: Bool = true
    @State private var selectedProduct: Product?
    @State private var isPurchased: Bool = false
    @State private var tippedAmount: Decimal = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    let sortedProducts = storeKit.storeProducts.sorted { product1, product2 in
                        // Define the desired order of product display names
                        let order: [String] = ["Small Tip", "Medium Tip", "Large Tip"]
                        
                        // Get the index of each product's display name in the order array
                        guard let index1 = order.firstIndex(of: product1.displayName),
                              let index2 = order.firstIndex(of: product2.displayName) else {
                            // If any product's display name is not found in the order array, maintain the current order
                            return false
                        }
                        
                        // Compare the indices to determine the order
                        return index1 < index2
                    }
                    
                    ForEach(sortedProducts) { product in
                        Tip(showLoading: showLoading,
                            productIsSelected: selectedProduct == product,
                            name: product.displayName,
                            price: product.displayPrice) {
                            selectedProduct = product
                            showLoading = true
                            Task {
                                let _ = try await storeKit.purchase(product)
                                showLoading = false
                            }
                        }
                        .onChange(of: storeKit.purchasedCourses) { course in
                            Task {
                                isPurchased = (try? await storeKit.isPurchased(product)) ?? false
                                if isPurchased {
                                    for course in storeKit.purchasedCourses {
                                        tippedAmount += course.price
                                    }
                                }
                            }
                        }
                    }
                } footer: {
                    Text("You have tipped a total amount of $\(String(describing: tippedAmount))")
                }
            }
            .navigationTitle("Tip Jar")
        }
    }
}

struct Tip: View {
    
    var showLoading: Bool
    var productIsSelected: Bool
    var name: String
    var price: String
    var action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            HStack {
                Text(name)
                Spacer()
                if showLoading && productIsSelected {
                    ProgressView()
                        .frame(height: 33)
                } else {
                    Text(price)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                        .frame(height: 30)
                        .padding(.horizontal, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Color.blue, lineWidth: 1.0)
                        }
                }
            }
            .padding(.vertical, 3.3)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    TipJarView()
}
