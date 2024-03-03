//
//  CoinModalView.swift
//  chatAi
//
//  Created by Apple on 2024/02/20.
//

import SwiftUI
import StoreKit

struct CoinModalView: View {
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @StateObject var store: Store = Store()
    @ObservedObject var reward = Reward()
    @State private var showAlert: Bool = false
    
    var body: some View {
//        NavigationView {
            ZStack {
                VStack{
                    VStack(spacing: -25) {
                        ForEach(store.productList, id: \.self) { product in
                            if product.displayName == "1000円" {
                                HStack{
                                    Image("390コイン")
                                        .resizable()
                                        .frame(width:150,height:45)
                                        .padding(.trailing,-10)
                                    
                                    Spacer()
                                    Button(action: {
                                        audioManager.playSound()
                                        Task {
                                            do {
                                                try await purchase(product) // 購入成功後にログ出力
                                            } catch {
                                                // エラーハンドリングをここで行う
                                                print("Purchase failed: \(error)")
                                            }
                                        }
                                    }) {
                                        Image("1000円で購入")
                                            .resizable()
                                            .frame(width:130,height:45)
                                            .shadow(radius: 3)
                                    }
                                    
                                }//.padding(.top,-20)
                            } else if product.displayName == "500円" {
                                HStack{
                                    Image("180コイン")
                                        .resizable()
                                        .frame(width:150,height:45)
                                        .padding(.trailing,-10)
                                        .padding(.top,-5)
                                    Spacer()
                                    Button(action: {
                                        audioManager.playSound()
                                        Task {
                                            do {
                                                try await purchase(product)
                                            } catch {
                                                // エラーハンドリングをここで行う
                                                print("Purchase failed: \(error)")
                                            }
                                        }
                                    }) {
                                        Image("500円で購入")
                                            .resizable()
                                            .frame(width:130,height:45)
                                            .shadow(radius: 3)
                                    }
                                }
                                .padding(.top,60)
                            } else {
                                HStack{
                                    Image("30コイン")
                                        .resizable()
                                        .frame(width:150,height:35)
                                        .padding(.trailing,-10)
                                    Spacer()
                                    Button(action: {
                                        audioManager.playSound()
                                        Task {
                                            do {
                                                try await purchase(product)
                                            } catch {
                                                // エラーハンドリングをここで行う
                                                print("Purchase failed: \(error)")
                                            }
                                        }
                                    }) {
                                        Image("100円で購入")
                                            .resizable()
                                            .frame(width:130,height:45)
                                            .shadow(radius: 3)
                                    }
                                }
                                .padding(.top,60)
                            }
                        }
                    }
                    .frame(width: isSmallDevice() ? 290: 310, height:250)
                    .padding()
                    .background(Color("background"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 15)
                    )
                    .foregroundColor(Color("fontGray"))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .overlay(
                        // 「×」ボタンを右上に配置
                        Button(action: {
                            audioManager.playCancelSound()
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .background(.white)
                                .cornerRadius(30)
                                .padding()
                        }
                            .offset(x: 35, y: -35), // この値を調整してボタンを正しい位置に移動させます
                        alignment: .topTrailing // 枠の右上を基準に位置を調整します
                    )
                    .padding(25)
                    Button(action: {
                        reward.ShowReward()
                    }) {
                        if reward.rewardLoaded == false {
                            Image("白黒動画視聴")
                                .resizable()
                                .frame(width:300,height:90)
                                .shadow(radius: 3)
                        }else{
                            Image("動画視聴")
                                .resizable()
                                .frame(width:300,height:90)
                                .shadow(radius: 3)
                        }
                    }
                    .disabled(!reward.rewardLoaded) // rewardLoadedを使用してボタンの活性状態を制御
                    .onChange(of: reward.rewardEarned) { rewardEarned in
                        showAlert = rewardEarned
                        print(":::::::::::reward.rewardEarned:\(reward.rewardEarned)")
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("報酬獲得！"),
                            message: Text("10コイン獲得しました。"),
                            dismissButton: .default(Text("OK"), action: {
                                // アラートを閉じるアクション
                                showAlert = false // アラートの表示状態を更新
                                reward.rewardEarned = false // 必要に応じてrewardEarnedも更新
                            })
                        )
                    }
                    NavigationLink(destination: SubscriptionView()) {
                        Image("プラミアムプラン")
                            .resizable()
                            .frame(width:280,height:90)
                            .shadow(radius: 3)
                    }
                    .padding(.top)
                }
                .onAppear{
                    reward.LoadReward()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print(store.productList)
                    }
                }
                
            }
//        }
//        .navigationBarBackButtonHidden(true)
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
//    CoinModalView(audioManager: AudioManager(), isPresented: .constant(true))
    TopView()
}

