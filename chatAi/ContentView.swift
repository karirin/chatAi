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
        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はライムだライム。はじめてですが、愛に溢れているのでお裾分けしてあげるライム。よろしくライム"),
        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    @State private var isCompleting: Bool = false
    @State private var text: String = ""
    @ObservedObject var authManager = AuthManager.shared
    @State private var imageOpacity = 1.0
    @State private var imageOpacities: [Int: Double] = [0: 1.0, 1: 1.0, 2: 1.0]
    @State private var coinPositions: [CGPoint] = []
    @State private var isPresentingChatHistoryView: Bool = false
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userLevel: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @State private var avatarHeart: Int = 0
    
    init() {
            // コインの初期位置を設定
            _coinPositions = State(initialValue: (0..<3).map { _ in
                // 画面の幅に合わせたランダムなX座標を生成
                let screenWidth = UIScreen.main.bounds.width
                let xPosition = CGFloat.random(in: 0...(screenWidth - 100))
                // Y座標は固定
                if isSmallDevice() {
                    let yPosition = CGFloat.random(in: UIScreen.main.bounds.height/4...UIScreen.main.bounds.height/3.8)
                    
                    return CGPoint(x: xPosition, y: yPosition)
                } else {
                    let yPosition = CGFloat.random(in: UIScreen.main.bounds.height/5...UIScreen.main.bounds.height/4.8)
                    
                    return CGPoint(x: xPosition, y: yPosition)
                }
            })
        }
    
    @State private var moveRight = true // ライムの画像が右に移動するかどうかを追跡

    let screenWidth = UIScreen.main.bounds.width
    let moveDistance: CGFloat = 300 // 移動距離の半分を設定
    @State private var limePositionX = UIScreen.main.bounds.width / 2 // ライムの初期位置X
    @State private var limePositionY = 350 // ライムの初期位置Y
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 1秒ごとに更新
    @State private var keyboardHeight: CGFloat = 0
    
    func randomDuration() -> Double {
        return Double.random(in: 0.5...4.0)
    }
    
    var body: some View {
        
        NavigationView{
            VStack{

                ZStack{
                    VStack{
                        Image("背景")
                            .resizable()
                            .frame(width:.infinity,height:250)
                        Spacer()
                    }
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
                                .onChange(of: lastMessage.role) { lastMessage in
                                    authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                                }
                        }
                    }
                    .position(x: isSmallDevice() ? UIScreen.main.bounds.width / 2 : UIScreen.main.bounds.width / 2, y:isSmallDevice() ? UIScreen.main.bounds.height / 10 : UIScreen.main.bounds.height / 12)
                    VStack{
                        Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .position(x: limePositionX, y:isSmallDevice() ? UIScreen.main.bounds.height/4:UIScreen.main.bounds.height/5)
                            .onReceive(timer) { _ in
                                withAnimation(.easeInOut(duration: self.randomDuration())) {
                                    // ランダムな位置に移動
                                    limePositionX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                                    limePositionY = Int(CGFloat.random(in: 350...370))
                                }
                            }
//                        Spacer()
                            
                    }
                }
                .frame(height: isSmallDevice() ? UIScreen.main.bounds.height/3 : UIScreen.main.bounds.height/3.5)
                VStack{
                    HStack{
//                        Image("レベル")
//                            .resizable()
//                            .frame(width:30,height:30)
//                        Text("Lv")
//                            .font(.system(size: 26))
//                            .padding(.trailing, -10)
//                        Text(" \(authManager.money)")
//                            .font(.system(size: 26))
                        ZStack{
                            Image("ハートバー")
                                .resizable()
                                .frame(width:90,height:45)
                            Text("\(authManager.level)")
//                            Text("12")
                                .font(.system(size: 18))
                                .padding(.leading,40)
                        }
                        ZStack{
                            Image("コインバー")
                                .resizable()
                                .frame(width:90,height:40)
                            Text("\(authManager.money)")
//                            Text("100")
                                .font(.system(size: 18))
                                .padding(.leading,40)
                        }
                        Button(action: {
                            
                        }) {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width:25,height:25)
                                .shadow(radius: 1)
                                .foregroundColor(Color("fontGray"))
                        }
                        Spacer()
                    }
                    .padding(.bottom,-3)
                    HStack{
                        Image("ハート")
                        .resizable()
                        .frame(width:40,height:40)
                        ProgressBar(value: Double(avatar.isEmpty ? 0 : (avatar.first?["heart"] as? Int) ?? 0), maxValue: 100, color: Color("hpMonsterColor"))
                            .frame(height: 20)
                        Text(" \(avatar.isEmpty ? 0 : (avatar.first?["heart"] as? Int) ?? 0)/100")
                    }
                }.padding(.horizontal)
                    .padding(.top,5)
//                ChatHistoryView()
//                VStack(spacing: -5){
//                    HStack{
//                        Button(action: {
//                            self.isPresentingChatHistoryView = true
//                        }) {
//                            HStack{
//                                Image(systemName: "bubble.left.and.bubble.right")
//                                Text("会話履歴")
//                            }
//                            .padding(8)
//                            .font(.system(size: 14))
//                            .background(Color.white)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(Color.gray, lineWidth: 1)
//                            )
//                            .cornerRadius(20)
//                            .padding(.leading)
//                            .shadow(radius: 1)
//                            .foregroundColor(Color("fontGray"))
//                            //                        .position(x: UIScreen.main.bounds.width / 2, y: 280)
//                        }
//                        Spacer()
//                    }
//                    
//                }
                ChatHistoryNotBtnView()
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
                        authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                        if let userId = authManager.currentUserId {
                            authManager.addHeartToAvatar(userId: userId, additionalHeart: 5) { success in
                                if success {
                                    print("Heart added successfully.")
                                } else {
                                    print("Failed to add heart.")
                                }
                            }
                        }
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
                Spacer()
            }
            .frame(maxHeight:.infinity)
            .background(Color("background"))
//            .padding(.bottom, keyboardHeight)
            .onAppear{
                authManager.updateCoinCountBasedOnLastLogin(userId: authManager.currentUserId!)
                authManager.fetchCoinCount()
                authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                    self.userName = name ?? ""
                    self.avatar = avatar ?? [[String: Any]]()
                    self.userMoney = money ?? 0
                    self.userHp = hp ?? 100
                    self.userAttack = attack ?? 20
                    self.tutorialNum = tutorialNum ?? 0
                    authManager.level = self.userLevel
                    authManager.money = self.userMoney
                    avatarHeart = self.avatar.first?["heart"] as! Int
//                    print(self.avatar.first?["heart"])
                }
//              }
            }
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
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

struct ProgressBar: View {
    var value: Double
    var maxValue: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.3)
                    .foregroundColor(color)
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(value / maxValue))
                    .foregroundColor(color)
            }
        }
        .cornerRadius(8.0)
    }
}

#Preview {
//    @State var chat = ChatMessage(role: .assistant, content: "私の名前はだっちゃんだっちゃ。はじめてですが、愛に溢れているのでお裾分けしてあげるだっちゃ。よろしくだっちゃ")
    
    
    ContentView()
}
