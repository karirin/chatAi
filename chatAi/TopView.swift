//
//  TopView.swift
//  chatAi
//
//  Created by Apple on 2024/02/17.
//

import SwiftUI

struct TopView: View {
    @ObservedObject var audioManager = AudioManager.shared
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
//            if isLoading == false {
//                //          if isLoading == true {
//                // ユーザー存在チェック中の表示 (例: ローディングインジケータ)
//                ActivityIndicator()
//            } else {
                TabView {
                    HStack{
                        ContentView()
                            .background(Color("sky"))
                    }
                    .tabItem {
                        Image(systemName: "house")
                            .padding()
                        Text("ホーム")
                            .padding()
                    }
                    ZStack {
                        ChatHistoryView()
                    }
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("会話")
                    }
                    ZStack {
                        ManagerView(audioManager: audioManager)
                    }
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("一覧")
                    }
                    ZStack {
                        ContactView()
                    }
                    .tabItem {
                        Image(systemName: "envelope")
                        Text("問い合わせ")
                    }
                    
                    //                BackGroundView()
                    //                        .tabItem {
                    //                            Image(systemName: "mountain.2")
                    //                            Text("エリア一覧")
                    //                        }
                    //                    PentagonView(authManager: authManager, flag: .constant(false))
                    //                GraphManagerView()
                    ////                    PentagonView(authManager: authManager, flag: .constant(false))
                    //                        .tabItem {
                    //                            Image(systemName: "chart.pie")
                    //                            Text("分析")
                    //                        }
                    SettingView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                        }
                }
            }
//        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isLoading = true
            }
        }
    }
}

#Preview {
    TopView()
}
