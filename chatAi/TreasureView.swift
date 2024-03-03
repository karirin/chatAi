//
//  TreasureView.swift
//  chatAi
//
//  Created by Apple on 2024/02/18.
//

import SwiftUI
import Firebase

struct TreasureView: View {
    @State private var showSpecialImage1 = false
    @State private var showSpecialImage2 = false
    @State private var showSpecialImage3 = false
    @State private var showSpecialImage4 = false
    @ObservedObject var authManager = AuthManager.shared
    let screenWidth = UIScreen.main.bounds.width
    @State private var positionX = UIScreen.main.bounds.width / Double.random(in: 1...10)
    @State private var userTreasures: [String: Bool] = [:]
    @State private var isCompleting: Bool = false
    @State private var imageOpacity1 = 1.0
    @State private var imageOpacity2 = 1.0
    @State private var imageOpacity3 = 1.0
    @State private var imageOpacity4 = 1.0
    @State private var usedBackground: Background?
    
    init(){
        _showSpecialImage1 = State(initialValue: Double.random(in: 0...1) < 1.05)
        _showSpecialImage2 = State(initialValue: Double.random(in: 0...1) < 1.03)
        _showSpecialImage3 = State(initialValue: Double.random(in: 0...1) < 1.01)
    }

    var body: some View {
        HStack{
            if let backgroundName = self.usedBackground?.name {
                if backgroundName == "背景1" {
                    if showSpecialImage1 && userTreasures["宝1"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝1")
                            authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 0) { success in
                            }
                            withAnimation {
                                imageOpacity1 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝1")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity1 ?? 1.0)
                    }
                    if showSpecialImage2 && userTreasures["宝2"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝2")
                            withAnimation {
                                imageOpacity2 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝2")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity2 ?? 1.0)
                    }
                    if showSpecialImage3 && userTreasures["宝3"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝3")
                            withAnimation {
                                imageOpacity3 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝3")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity3 ?? 1.0)
                    }
                    
                }
                else if backgroundName == "背景2" {
                    if showSpecialImage1 && userTreasures["宝4"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝4")
                            withAnimation {
                                imageOpacity1 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝4")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity1 ?? 1.0)
                    }
                    
                    
                    
                    if showSpecialImage2 && userTreasures["宝5"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝5")
                            withAnimation {
                                imageOpacity2 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝5")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity2 ?? 1.0)
                    }
                    if showSpecialImage3 && userTreasures["宝6"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝6")
                            withAnimation {
                                imageOpacity3 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝6")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity3 ?? 1.0)
                    }
                    
                }
                else if backgroundName == "背景3"  {
                    if showSpecialImage1 && userTreasures["宝7"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝7")
                            withAnimation {
                                imageOpacity1 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝7")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity1 ?? 1.0)
                    }
                    if showSpecialImage2 && userTreasures["宝8"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝8")
                            withAnimation {
                                imageOpacity2 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝8")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity2 ?? 1.0)
                    }
                    
                    
                    
                    if showSpecialImage3 && userTreasures["宝9"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝9")
                            withAnimation {
                                imageOpacity3 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝9")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity3 ?? 1.0)
                    }
                    
                }
                else if backgroundName == "背景4"  {
                    if showSpecialImage1 && userTreasures["宝10"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝10")
                            withAnimation {
                                imageOpacity1 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝10")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity1 ?? 1.0)
                    }
                    if showSpecialImage2 && userTreasures["宝11"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝11")
                            withAnimation {
                                imageOpacity2 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝11")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity2 ?? 1.0)
                    }
                    if showSpecialImage3 && userTreasures["宝12"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝12")
                            withAnimation {
                                imageOpacity3 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝12")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity3 ?? 1.0)
                    }
                    
                }
                else if backgroundName == "背景5"  {
                    
                    if showSpecialImage1 && userTreasures["宝13"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝13")
                            withAnimation {
                                imageOpacity1 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝13")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity1 ?? 1.0)
                    }
                    if showSpecialImage2 && userTreasures["宝14"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝14")
                            withAnimation {
                                imageOpacity2 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝14")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity2 ?? 1.0)
                    }
                    if showSpecialImage3 && userTreasures["宝15"] != true {
                        Button(action: {
                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝15")
                            withAnimation {
                                imageOpacity3 = 0.0 // そのコインの透明度を更新
                            }
                        }) {
                            Image("宝15")
                                .resizable()
                                .frame(width: 100, height: 100)
                            // 画像の位置やその他のスタイルを設定
                                .position(x: positionX, y: 125)
                        }
                        .opacity(imageOpacity3 ?? 1.0)
                    }
                }
            }
        }
        .onAppear{
            self.fetchUserTreasures(userId: authManager.currentUserId!)
            authManager.fetchUsedBackgrounds { usedBackgrounds in
                self.usedBackground = usedBackgrounds.first { $0.usedFlag == 1 }
                print(self.usedBackground)
            }
        }
    }
    
    // ユーザーの称号データを取得する関数
    func fetchUserTreasures(userId: String) {
        
        print("self.userTreasures")
        let treasuresRef = Database.database().reference().child("treasures").child(userId)
        treasuresRef.observeSingleEvent(of: .value) { snapshot in
            if let treasures = snapshot.value as? [String: Bool] {
                self.userTreasures = treasures
                print("self.userTreasures:\(self.userTreasures)")
            }
        }
    }

}

#Preview {
    TreasureView()
}
