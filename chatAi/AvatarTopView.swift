//
//  AvatarView.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI
import OpenAIKit

struct AvatarTopView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var imageOpacities: [Int: Double] = [0: 1.0, 1: 1.0, 2: 1.0]
    @State private var coinPositions: [CGPoint] = []
    @State private var chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "こちらではAIアシスタントのだっちゃんが会話を行います。だっちゃんは語尾に必ずだっちゃを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はだっちゃんだっちゃ。はじめてですが、愛に溢れているのでお裾分けしてあげるだっちゃ。よろしくだっちゃ"),
        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    @State private var limePositionX = UIScreen.main.bounds.width / 2 // ライムの初期位置X
    @State private var limePositionY = 350 // ライムの初期位置Y
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 1秒ごとに更新
    func randomDuration() -> Double {
        return Double.random(in: 0.5...4.0)
    }
    
    init() {
            // コインの初期位置を設定
            _coinPositions = State(initialValue: (0..<3).map { _ in
                // 画面の幅に合わせたランダムなX座標を生成
                let screenWidth = UIScreen.main.bounds.width
                let xPosition = CGFloat.random(in: 0...(screenWidth - 100))
                // Y座標は固定
                let yPosition = CGFloat.random(in: 400...420)
                return CGPoint(x: xPosition, y: yPosition)
            })
        }
    
    var body: some View {
        ZStack{
            Image("背景")
                .resizable()
                .frame(width:.infinity,height:250)
            //                ForEach(0..<authManager.coinCount, id: \.self) { index in
            ForEach(0..<3, id: \.self) { index in
                Button(action: {
                    authManager.addMoney(amount: 1)
                    withAnimation {
                        imageOpacities[index] = 0.0 // そのコインの透明度を更新
                    }
                }) {
                    Image("コイン")
                        .resizable()
                        .frame(width:60,height:60)
                        .opacity(imageOpacities[index] ?? 1.0)
                    //                            .position(y:200)
                }
                .buttonStyle(PlainButtonStyle())
                .position(coinPositions[index])
                
            }
            
            VStack{
                if let lastMessage = chat.last {
                    MessageAvatarView(message: lastMessage)
//                    MessageAvatarView()
                }
            }
            .position(x: UIScreen.main.bounds.width / 2, y: 280)
            Image("ライム")
                .resizable()
                .frame(width: 150, height: 150)
                .position(x: limePositionX, y: 380)
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut(duration: self.randomDuration())) {
                        // ランダムな位置に移動
                        limePositionX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                        limePositionY = Int(CGFloat.random(in: 350...370))
                    }
                }
        }
    }
}

#Preview {
    AvatarTopView()
}
