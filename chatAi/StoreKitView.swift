//
//  StoreKitView.swift
//  chatAi
//
//  Created by Apple on 2024/02/20.
//

import SwiftUI
import Foundation
import StoreKit

class Store: ObservableObject {
    
    private var updates: Task<Void, Never>? = nil
    @Published var productList: [Product]
    @ObservedObject var authManager = AuthManager.shared
    
    init() {
//        updates = newTransactionListenerTask()
        productList = []

      Task {
          await fetchProducts()
      }
    }
    
    deinit {
        updates?.cancel()
    }
    
    @MainActor
    func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: ["chat.coin30", "chat.coin180", "chat.coin390"])
//            let fetchedProducts = try await Product.products(for: ["consumable.it1", "consumable.it2", "consumable.it3"])
            
            // コインの量に基づいてソート
            productList = fetchedProducts.sorted { product1, product2 in
                // name属性からコインの量を表す数値を抽出
                let value1 = Int(product1.displayName.filter("0123456789".contains)) ?? 0
                let value2 = Int(product2.displayName.filter("0123456789".contains)) ?? 0
                return value1 > value2
            }
        } catch {
            print("製品の取得に失敗しました: \(error)")
        }
    }

    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                guard
                    case .verified(let transaction) = verificationResult,
                    transaction.revocationDate == nil // 払い戻されたものは無視する
                else { return }
                
                // 購入情報の更新
                await refreshPurchasedProducts()
                
                await transaction.finish()
            }
        }
    }
}
    
func refreshPurchasedProducts() async {
    for await verificationResult in Transaction.currentEntitlements {
        // 取り消しや払い戻された transaction は currentEntitlements には現れないので
        // transaction.revocationDate はチェックしなくて良い
        guard case .verified(let transaction) = verificationResult else { return }

            switch transaction.productType {
            case .consumable:
                // transaction が終了していなかった consumable が来る
                let amount = UserDefaults.standard.integer(forKey: transaction.productID)
                UserDefaults.standard.set(amount + 1, forKey: transaction.productID)
            default:
                break
        }
    }
}

func purchase(_ product: Product) async throws {
    let result = try await product.purchase()
    @ObservedObject var authManager = AuthManager.shared

    switch result {
    case let .success(verificationResult):
        print("verificationResult1:\(verificationResult)")
        switch verificationResult {
        case let .verified(transaction):
            print("verificationResult2:\(transaction.price)")
            if transaction.price == 1000 {
                authManager.addMoney(amount: 390)
            } else if transaction.price == 500 {
                authManager.addMoney(amount: 180)
            } else {
                authManager.addMoney(amount: 30)
            }
            // 購入情報を更新する
           await refreshPurchasedProducts()

           // consumable については refreshPurchasedProducts() で更新できなかったのでここで更新
           // currentEntitlements の説明では更新できそうに思えたができなかった
           if case .consumable = transaction.productType {
               let amount = UserDefaults.standard.integer(forKey: transaction.productID)
               UserDefaults.standard.set(amount + 1, forKey: transaction.productID)
           }

            // transaction を終了させる必要がある
            await transaction.finish()

        case let .unverified(_, verificationError):
            // StoreKit の validation が通らなかった場合
            // 自分で validate することができる
            throw verificationError
        }
    case .pending:
        // ユーザーのアクションが必要
        // transaction が終わったら Transaction.updates から取れる
        break
    case .userCancelled:
        // ユーザーがキャンセルした
        break
    @unknown default:
        break
    }
}

struct StoreKitView: View {

    @StateObject var store: Store = Store()
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        List {
            Section("") {
                ForEach(store.productList, id: \.self) { product in
                    HStack {
                        Text("\(product.displayName)")

                        Spacer()

                        Button {
                            Task {
                                   do {
                                       try await purchase(product)
                                   } catch {
                                       // エラーハンドリングをここで行う
                                       print("Purchase failed: \(error)")
                                   }
                               }
                            if product.displayName == "100コイン" {
                                self.authManager.addMoney(amount: 100)
                            }else if product.displayName == "50コイン"{
                                self.authManager.addMoney(amount: 50)
                            }else{
                                self.authManager.addMoney(amount: 10)
                            }
                        } label: {
                            Text("購入")
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }
                .onAppear{
                    print("store.productList:\(store.productList)")
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
}

#Preview {
    StoreKitView()
}

