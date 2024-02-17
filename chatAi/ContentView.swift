//
//  ContentView.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI
import OpenAIKit

struct ContentView: View {
    @State private var chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "こちらではAIアシスタントのだっちゃんが会話を行います。だっちゃんは語尾に必ずだっちゃを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はだっちゃんだっちゃ。はじめてですが、愛に溢れているのでお裾分けしてあげるだっちゃ。よろしくだっちゃ"),
        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    @State private var isCompleting: Bool = false
    @State private var text: String = ""
    @ObservedObject var authManager = AuthManager.shared
    @State private var imageOpacity = 1.0
    @State private var imageOpacities: [Int: Double] = [0: 1.0, 1: 1.0, 2: 1.0]
    @State private var coinPositions: [CGPoint] = []
    
//    init() {
//            // コインの初期位置を設定
//            _coinPositions = State(initialValue: (0..<3).map { _ in
//                // 画面の幅に合わせたランダムなX座標を生成
//                let screenWidth = UIScreen.main.bounds.width
//                let xPosition = CGFloat.random(in: 0...(screenWidth - 100))
//                // Y座標は固定
//                let yPosition = CGFloat.random(in: 400...420)
//                return CGPoint(x: xPosition, y: yPosition)
//            })
//        }
    
    @State private var moveRight = true // ライムの画像が右に移動するかどうかを追跡

    let screenWidth = UIScreen.main.bounds.width
    let moveDistance: CGFloat = 300 // 移動距離の半分を設定
    @State private var limePositionX = UIScreen.main.bounds.width / 2 // ライムの初期位置X
    @State private var limePositionY = 350 // ライムの初期位置Y
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 1秒ごとに更新
    
    func randomDuration() -> Double {
        return Double.random(in: 0.5...4.0)
    }
    
    var body: some View {
        VStack{
               AvatarTopView()
//            Spacer()
//        VStack(alignment: .leading) {
//            ForEach(chat.indices, id: \.self) { index in
//                // 最初のメッセージ以外を表示
//                if index > 1 {
//                    MessageAvatarView(message: chat[index])
//                }
//            }
            
            Spacer()
//        }
//        .padding(.vertical, 5)
        HStack {
            // テキスト入力フィールド
            TextField("メッセージを入力", text: $text)
                .disabled(isCompleting) // チャットが完了するまで入力を無効化
                .font(.system(size: 15)) // フォントサイズを調整
                .padding(8)
                .padding(.horizontal, 10)
                .background(Color.white) // 入力フィールドの背景色を白に設定
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)

                )
            
            // 送信ボタン
            Button(action: {
                isCompleting = true
                // ユーザーのメッセージをチャットに追加
                chat.append(ChatMessage(role: .user, content: text))
                text = "" // テキストフィールドをクリア
                
                Task {
                    do {
                        // OpenAIの設定
                        let config = Configuration(
                            organizationId: "org-dPUAuIy1CBxghho0gfTEk53n",
                            apiKey: "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"
                        )
                        let openAI = OpenAI(config)
                        let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-3.5-turbo")!, messages: chat)
                        
                        // チャットの生成
                        let chatCompletion = try await openAI.generateChatCompletion(
                            parameters: chatParameters
                        )
                        
                        isCompleting = false
                        // AIのレスポンスをチャットに追加
                        chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message?.content))
                    } catch {
                        print("ERROR DETAILS - \(error)")
                    }
                }
            }) {
                // 送信ボタンのデザイン
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(self.text == "" ? Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.8, alpha: 1)) : Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
            }
            // テキストが空またはチャットが完了していない場合はボタンを無効化
            .disabled(self.text == "" || isCompleting)
        }
        .padding(.horizontal)
        .padding(.bottom, 8) // 下部のパディングを調整
    }
        .onAppear{
            authManager.fetchCoinCount()
        }
//            if let userId = authManager.currentUserId {
//                authManager.fetchLastLoginDate(userId: userId) { lastLoginDate in
//                    let currentDate = Date()
//                    if let lastLoginDate = lastLoginDate {
//                        let timeInterval = currentDate.timeIntervalSince(lastLoginDate)
//                        if timeInterval >= 86400 {
//                            authManager.saveLastLoginDate(userId: userId) { success in
//                                if success {
//                                    print("ログインボーナスの日時を保存しました")
//                                } else {
//                                    print("ログインボーナスの日時の保存に失敗しました")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    func randomXPosition() -> CGFloat {
        // ここで画面の幅に合わせたランダムなX座標を生成します。
        // この例では画面の幅を300と仮定していますが、実際のデバイスの幅に合わせてください。
        let screenWidth = 500.0 // UIScreen.main.bounds.widthを使うとデバイスの幅が取得できます。
        let xPosition = CGFloat.random(in: 0...(screenWidth - 80)) // 画像の幅を引いています。
        return xPosition
    }
}

#Preview {
//    @State var chat = ChatMessage(role: .assistant, content: "私の名前はだっちゃんだっちゃ。はじめてですが、愛に溢れているのでお裾分けしてあげるだっちゃ。よろしくだっちゃ")
    
    
    ContentView()
}
