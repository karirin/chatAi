//
//  ContentView.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI
import Firebase
import OpenAIKit

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey2: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey3: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey4: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey5: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ContentView: View {
//    @State private var chat: [ChatMessage] = [
//        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
////        ChatMessage(role: .assistant, content: "私の名前はライムだライム。はじめてですが、愛に溢れているのでお裾分けしてあげるライム。よろしくライム"),
////        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
//    ]
    @State private var chat: [ChatMessage] = [
//        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。")
        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
//    @State private var chat: [ChatMessage] = []
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
    @State private var userFlag: Int = 0
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @State private var avatarHeart: Int = 0
    @State private var showSpecialImage = false
    @State private var isAvatarBlushing: Bool = false
    @State private var flag1: Bool = false
    @State private var flag2: Bool = false
    @State private var flag3: Bool = false
    @State private var flag4: Bool = false
    @State private var flag5: Bool = false
    @State private var flag6: Bool = false
    @State private var flag7: Bool = false
    @State private var flag8: Bool = false
    @State private var flag9: Bool = false
    @State private var flag10: Bool = false
    @State private var flag11: Bool = false
    @State private var flag12: Bool = false
    @State private var flag13: Bool = false
    @State private var flag14: Bool = false
    @State private var flag15: Bool = false
    @State private var backgroundFlag1: Bool = false
    @State private var backgroundFlag2: Bool = false
    @State private var backgroundFlag3: Bool = false
    @State private var backgroundFlag4: Bool = false
    @State private var helpFlag: Bool = false
    @State private var csFlag: Bool = false
    @State private var adFlag: Bool = false
    @State private var nameModalFlag: Bool = false
    @ObservedObject var appState = AppState()
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    
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
            _showSpecialImage1 = State(initialValue: Double.random(in: 0...1) < 0.03)
            _showSpecialImage2 = State(initialValue: Double.random(in: 0...1) < 0.05)
            _showSpecialImage3 = State(initialValue: Double.random(in: 0...1) < 0.08)
            _showSpecialImage4 = State(initialValue: Double.random(in: 0...1) < 0.10)
            
//        avatarLoader.fetchAvatarsAndCreateMessages { newChatMessages in
//            self.chat = newChatMessages
//        }

        // アバターデータを非同期で取得し、取得後にchat配列を更新
//        authManager.fetchUsedAvatars { [weak self] avatars in
//            guard let self = self else { return }
//            var newChatMessages = [
//                ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。")
//            ]
//            
//            // 取得したアバターデータを使用してメッセージを追加
//            avatars.forEach { avatar in
//                newChatMessages.append(ChatMessage(role: .system, content: avatar.system))
//            }
//            
//            // chat配列を更新
//            DispatchQueue.main.async {
//                self.chat = newChatMessages
//            }
//        }
        }
    @State private var loadedMessages: [ChatMessage] = []
    @State private var loadRecentMessages: [ChatMessage] = []
    @State private var moveRight = true // ライムの画像が右に移動するかどうかを追跡

    let screenWidth = UIScreen.main.bounds.width
    let moveDistance: CGFloat = 300 // 移動距離の半分を設定
    @State private var limePositionX = UIScreen.main.bounds.width / 2 // ライムの初期位置X
    @State private var limePositionY = 350 // ライムの初期位置Y
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 1秒ごとに更新
    @State private var keyboardHeight: CGFloat = 0
    @State private var showSpecialImage1 = false
    @State private var showSpecialImage2 = false
    @State private var showSpecialImage3 = false
    @State private var showSpecialImage4 = false
    @State private var showCoinModal = false
    @State private var showUnCoinModal = false
    @State private var chatFlag = false
    @State private var tutorialStart = false
    @State private var positionX = UIScreen.main.bounds.width / Double.random(in: 1...10)
    @State private var userTreasures: [String: Bool] = [:]
    @State private var imageOpacity1 = 1.0
    @State private var imageOpacity2 = 1.0
    @State private var imageOpacity3 = 1.0
    @State private var imageOpacity4 = 1.0
    @State private var usedBackground: Background?
    @ObservedObject var audioManager = AudioManager.shared
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State private var buttonRect4: CGRect = .zero
    @State private var bubbleHeight4: CGFloat = 0.0
    @State private var buttonRect5: CGRect = .zero
    @State private var bubbleHeight5: CGFloat = 0.0
    @FocusState private var isTextFieldFocused: Bool
    @State var isLoading : Bool = true
    @ObservedObject var interstitial = Interstitial()
    
    func randomDuration() -> Double {
        return Double.random(in: 0.5...4.0)
    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        
        NavigationView{
            VStack{
                ZStack{
                    VStack{
                        
                        ZStack{
                            VStack{
                                Image(authManager.usedBackgroundName)
                                    .resizable()
                                    .frame(width:.infinity,height:isIPad() ? 430 : isSmallDevice() ? 270 : 240)
                                Spacer()
                            }
                            
                            HStack{
                                if authManager.usedBackgroundName == "背景1" {
                                    if showSpecialImage4 && userTreasures["宝1"] != true {
                                        //                                    if userTreasures["宝1"] == true {
                                        Button(action: {
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝1")
                                            authManager.updateUserFlag(userId: authManager.currentUserId!, userFlag: 0) { success in
                                            }
                                            flag1 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝2")
                                            flag2 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝3")
                                            flag3 = true
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
                                else if authManager.usedBackgroundName == "背景2" {
                                    if showSpecialImage1 && userTreasures["宝4"] != true {
                                        Button(action: {
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝4")
                                            flag4 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝5")
                                            flag5 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝6")
                                            flag6 = true
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
                                else if authManager.usedBackgroundName == "背景3"  {
                                    if showSpecialImage1 && userTreasures["宝7"] != true {
                                        Button(action: {
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝7")
                                            flag7 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝8")
                                            flag8 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝9")
                                            flag9 = true
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
                                else if authManager.usedBackgroundName == "背景4"  {
                                    if showSpecialImage1 && userTreasures["宝10"] != true {
                                        Button(action: {
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝10")
                                            flag10 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝11")
                                            flag11 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝12")
                                            flag12 = true
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
                                else if authManager.usedBackgroundName == "背景5"  {
                                    
                                    if showSpecialImage1 && userTreasures["宝13"] != true {
                                        Button(action: {
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝13")
                                            flag13 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝14")
                                            flag14 = true
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
                                            audioManager.playTreasureSound()
                                            authManager.saveTreasureForUser(userId: authManager.currentUserId!, treasure: "宝15")
                                            flag15 = true
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
                            ForEach(0..<authManager.coinCount, id: \.self) { index in
                                //                        ForEach(0..<3, id: \.self) { index in
                                Button(action: {
                                    authManager.addMoney(amount: 1)
                                    authManager.decreaseUserCoinCount(){ success in
                                        
                                    }
                                    audioManager.playCoinSound()
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
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        //                                helpFlag = true
                                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                                        }
                                        audioManager.playSound()
                                        authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                                            self.userName = name ?? ""
                                            self.avatar = avatar ?? [[String: Any]]()
                                            self.userMoney = money ?? 0
                                            self.userHp = hp ?? 100
                                            self.userAttack = attack ?? 20
                                            self.tutorialNum = tutorialNum ?? 0
                                            self.userFlag = userFlag ?? 0
                                        }
                                    }) {
                                        Image(systemName: "questionmark.circle.fill")
                                            .resizable()
                                            .frame(width:35,height:35)
                                        //                                        .shadow(radius: 1)
                                            .foregroundColor(Color("fontGray"))
                                    }
                                    .padding()
                                    .padding(.top,20)
                                }
                                Spacer()
                            }
                            VStack{
                                //                        if let lastMessage = chat.last {
                                MessageAvatarView(message: chat.last!, tutorialNum: tutorialNum, tutorialStart: $tutorialStart, chatFlag: $chatFlag)
                                    .background(GeometryReader { geometry in
                                        Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                                    })
                                    .onChange(of: chat.last!.content) { _ in
                                        print("message.content:\(chat.last!.content)")
                                    }
                                //                        }
                            }
                            .position(x: isSmallDevice() ? UIScreen.main.bounds.width / 2 : UIScreen.main.bounds.width / 2, y:isSmallDevice() ? UIScreen.main.bounds.height / 9 : UIScreen.main.bounds.height / 18)
                            VStack{
                                Image(isAvatarBlushing ? "\(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")_照れ" : avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                                    .resizable()
                                    .frame(width: 140, height: 140)
                                    .position(x: limePositionX, y: isSmallDevice() ? UIScreen.main.bounds.height / 3.8 : UIScreen.main.bounds.height / 5.5)
                                    .onReceive(timer) { _ in
                                        withAnimation(.easeInOut(duration: self.randomDuration())) {
                                            // ランダムな位置に移動
                                            limePositionX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                                            limePositionY = Int(CGFloat.random(in: 350...370))
                                        }
                                    }
                                    .onTapGesture {
                                        // クリックされたら照れ画像を表示
                                        audioManager.playTouchSound()
                                        chatFlag = true
                                        isAvatarBlushing = true
                                        isTextFieldFocused = true
                                        // 3秒後に元の画像に戻す
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            isAvatarBlushing = false
                                            chatFlag = false
                                        }
                                    }
                                //                        Spacer()
                                
                            }
                        }
                        
                        .frame(height: isSmallDevice() ? UIScreen.main.bounds.height/3 : UIScreen.main.bounds.height/3.5)
                        VStack{
                            HStack{
                                ZStack{
                                    Image("ハートバー")
                                        .resizable()
                                        .frame(width:110,height:45)
                                    Text("\(authManager.usedAvatarHeart)")
                                    //                                Text("10")
                                        .font(.system(size: 20))
                                        .padding(.leading,45)
                                        .padding(.top,5)
                                }
                                .background(GeometryReader { geometry in
                                    Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                                })
                                ZStack{
                                    Image("コインバー")
                                        .resizable()
                                        .frame(width:120,height:50)
                                    Text("\(authManager.money)")
                                    //                                Text("10")
                                        .padding(.leading,55)
                                        .font(.system(size: 20))
                                        .padding(.top,1)
                                }
                                .background(GeometryReader { geometry in
                                    Color.clear.preference(key: ViewPositionKey4.self, value: [geometry.frame(in: .global)])
                                })
                                Spacer()
                                ZStack{
                                        Button(action: {
                                            showCoinModal = true
                                        }) {
                                            Image("コイン追加ボタン")
                                                .resizable()
                                                .frame(width:100,height:35)
                                                .shadow(radius: 1)
                                        }
//                                    Text("\(authManager.money)")
//    //                                Text("10")
//                                        .padding(.leading,55)
//                                        .font(.system(size: 20))
//                                        .padding(.top,1)
                                }
                            }
                        }.padding(.horizontal)
                            .padding(.top,10)
                            .padding(.bottom,-10)
                        VStack {
                            // スクロール可能なメッセージリストの表示
                            ScrollViewReader { scrollViewProxy in
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        if tutorialNum == 5 {
                                        VStack{
                                            HStack{
                                                AvatarView(imageName: "avatar")
                                                    .padding(.trailing, 8)
                                                Text("はじめまして！\(self.userName)！\(authManager.usedAvatarName)だよ♪\n雑談、悩み、恋話、なんでも話してね♪♪")
                                                    .padding(10)
                                                    .background(Color("chatColor"))
                                                    .cornerRadius(20)
                                            }
                                            HStack{
                                                Spacer()
                                                Text("よろしくね！")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.black)
                                                    .padding(10)
                                                    .background(Color("chatUserColor"))
                                                    .cornerRadius(20) // 角を丸くする
                                                VStack{
                                                    Image(systemName: "person.crop.circle")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                    Text(userName)
                                                        .font(.caption)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                        }.padding()
                                            
                                        }
                                        ForEach(loadedMessages.indices, id: \.self) { index in
                                            MessageView(message: loadedMessages[index],nameModalFlag: $nameModalFlag, audioManager: audioManager)
                                        }
                                        //                    ForEach(chat.indices, id: \.self) { index in
                                        //                        // 最初のメッセージ以外を表示
                                        //                        if index > 1 {
                                        //                            MessageView(message: chat[index])
                                        ////                                .opacity(0)/
                                        //                        }
                                        //                    }
                                    }
                                }
                                .background(GeometryReader { geometry in
                                    Color.clear.preference(key: ViewPositionKey5.self, value: [geometry.frame(in: .global)])
                                })
                                .onChange(of: loadedMessages.count) { _ in
                                    // メッセージの数が変わるたびに最下部にスクロール
                                    if let lastMessageIndex = loadedMessages.indices.last {
                                        scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                                    }
                                }
                                .onAppear{
                                    if let userId = authManager.currentUserId {
                                        authManager.loadMessages(userId: userId) { messages in
                                            self.loadedMessages = messages
                                            print("self.loadedMessages:\(self.loadedMessages)")
                                            // メッセージの読み込み後、少し遅延させて最下部にスクロール
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 0.1秒後に実行
                                                if let lastMessageIndex = loadedMessages.indices.last {
                                                    print("lastMessageIndex:\(lastMessageIndex)")
                                                    scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            //                                .padding(.top)
                            
                            
                            if authManager.userPreFlag != 1 {
                                BannerView()
                                    .frame(height:40)
                            }
                            // テキスト入力フィールドと送信ボタンの表示
                            HStack {
                                
                                // テキスト入力フィールド
                                TextField("メッセージを入力", text: $text)
                                    .focused($isTextFieldFocused)
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
                                    executeProcessEveryTenTimes()
                                    if authManager.money <= 0 {
                                        text = ""
                                        showUnCoinModal = true
                                    }else{
                                        // ボタンが押されたことを示すフラグをセット
                                        isCompleting = true
                                        
                                        // 送信するメッセージを作成
                                        let newMessage = ChatMessage(role: .user, content: text)
                                        text = ""
                                        // メッセージをFirebaseに保存
                                        authManager.saveMessage(userId: authManager.currentUserId!, message: newMessage)
                                        if let userId = authManager.currentUserId {
                                            authManager.addHeartToAvatar(userId: userId, additionalHeart: 5) { success in
                                                if success {
                                                } else {
                                                    print("Failed to add heart.")
                                                }
                                            }
                                            if tutorialNum == 1 {
                                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                                }
                                            }
                                            if authManager.userPreFlag != 1 {
                                                authManager.decreaseUserMoney(by: 1) { success in
                                                    if success {
                                                        
                                                        authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                                                            self.userName = name ?? ""
                                                            self.avatar = avatar ?? [[String: Any]]()
                                                            self.userMoney = money ?? 0
                                                            self.userHp = hp ?? 100
                                                            self.userAttack = attack ?? 20
                                                            self.tutorialNum = tutorialNum ?? 0
                                                            self.userFlag = userFlag ?? 0
                                                            authManager.level = self.userLevel
                                                            authManager.money = self.userMoney
                                                            authManager.usedAvatarHeart = self.avatar.first?["heart"] as! Int
                                                            authManager.fetchUsedAvatars() { success in
                                                            }
                                                        }
                                                        print("self.userMoney - 1")
                                                        //                                                authManager.money - 1
                                                        
                                                    }
                                                }
                                            }else{
                                                authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                                                    self.userName = name ?? ""
                                                    self.avatar = avatar ?? [[String: Any]]()
                                                    self.userMoney = money ?? 0
                                                    self.userHp = hp ?? 100
                                                    self.userAttack = attack ?? 20
                                                    self.tutorialNum = tutorialNum ?? 0
                                                    self.userFlag = userFlag ?? 0
                                                    authManager.level = self.userLevel
                                                    authManager.money = self.userMoney
                                                    authManager.usedAvatarHeart = self.avatar.first?["heart"] as! Int
                                                    authManager.fetchUsedAvatars() { success in
                                                    }
                                                }
                                            }
                                        }
                                        Task {
                                            do {
                                                // OpenAIの設定
                                               //ここ
                                                let openAI = OpenAI(config)
                                                let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-4")!, messages: chat + [newMessage])
                                                print("chat@@@@@@@:\(chat)")
                                                // チャットの生成
                                                let chatCompletion = try await openAI.generateChatCompletion(
                                                    parameters: chatParameters
                                                )
                                                
                                                // AIのレスポンスをチャットに追加
                                                DispatchQueue.main.async {
                                                    chat.append(newMessage)
                                                    chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message?.content))
                                                    authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                                                    // 処理が完了したのでフラグをクリア
                                                    isCompleting = false
                                                }
                                            } catch {
                                                DispatchQueue.main.async {
                                                    // エラーが発生した場合の処理
                                                    print("ERROR DETAILS - \(error)")
                                                    // 処理が完了したのでフラグをクリア
                                                    isCompleting = false
                                                }
                                            }
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
                                .onChange(of: chat.last?.role) { lastMessage in
                                    print("fetchCoinCount")
                                    authManager.fetchCoinCount()
                                    //                        authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                                }
                            }
                            
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                            })
                            .padding(.horizontal)
                            //                                .padding(.bottom, 8)  // 下部のパディングを調整
                            
                        }
                        .background(Color("background"))
                        Spacer()
                    }
                    .onPreferenceChange(ViewPositionKey.self) { positions in
                        self.buttonRect = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey2.self) { positions in
                        self.buttonRect2 = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey3.self) { positions in
                        self.buttonRect3 = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey4.self) { positions in
                        self.buttonRect4 = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey5.self) { positions in
                        self.buttonRect5 = positions.first ?? .zero
                    }
                    if tutorialStart == true && tutorialNum == 0 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                            //                            .overlay(
                            //                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                            //                                    .frame(width: buttonRect4.width, height: buttonRect4.height)
                            //                                    .position(x: buttonRect4.midX, y: buttonRect4.midY)
                            //                                    .blendMode(.destinationOut)
                            //                            )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                                .onTapGesture{
                                    tutorialNum = 1 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                                    }
                                }
                        }
                        VStack {
                            Spacer()
                            //                            .frame(height: buttonRect4.minY + bubbleHeight4 - 70)
                            VStack(alignment: .trailing, spacing: .zero) {
                                
                                //                        Image("上矢印")
                                //                            .resizable()
                                //                            .frame(width: 20, height: 20)
                                //                            .padding(.trailing, 180)
                                Text("ダウンロードありがとうございます！\n\nこのアプリは「おとも」というキャラクターと楽しく会話するアプリです。\n最初に簡単な操作説明をします。")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .onTapGesture{
                                audioManager.playSound()
                                tutorialNum = 6 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                                }
                            }
                            //                        .background(GeometryReader { geometry in
                            //                            Path { _ in
                            //                                DispatchQueue.main.async {
                            //                                    self.bubbleHeight4 = geometry.size.height
                            //                                }
                            //                            }
                            //                        })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        VStack{
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 6 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if tutorialNum == 1 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .frame(width: buttonRect.width, height: buttonRect.height)
                                        .position(x: buttonRect.midX, y: buttonRect.midY)
                                        .blendMode(.destinationOut)
                                )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                                .onTapGesture{
                                    audioManager.playSound()
                                    tutorialNum = 2 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                                    }
                                }
                        }
                        VStack {
                            Spacer()
                                .frame(height: buttonRect.minY + bubbleHeight-120)
                            VStack(alignment: .trailing, spacing: .zero) {
                                Text("おともと会話するには\nメッセージを入力して(↑)ボタンをクリックします")
                                    .padding(5)
                                    .font(.callout)
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                                //                            Image("下矢印")
                                //                                .resizable()
                                //                                .frame(width: 20, height: 20)
                                //                                .padding(.trailing, 30)
                            }
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 2 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                            }
                        }
                        VStack{
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if tutorialNum == 2 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .frame(width: buttonRect2.width-30, height: buttonRect2.height)
                                        .position(x: buttonRect2.midX, y: buttonRect2.midY)
                                        .blendMode(.destinationOut)
                                )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                        }.onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 3 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                            }
                        }
                        VStack {
                            Spacer()
                                .frame(height: buttonRect2.minY + bubbleHeight2 - 0)
                            VStack(alignment: .trailing, spacing: .zero) {
                                
                                //                        Image("上矢印")
                                //                            .resizable()
                                //                            .frame(width: 20, height: 20)
                                //                            .padding(.trailing, 180)
                                Text("おともから返事が返ってきます。\n会話を続けておともと仲良くしましょう。")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .background(GeometryReader { geometry in
                                Path { _ in
                                    DispatchQueue.main.async {
                                        self.bubbleHeight2 = geometry.size.height
                                    }
                                }
                            })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 3 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                            }
                        }
                        VStack{
                            Spacer()
                                .frame(height: buttonRect2.minY + bubbleHeight2+100)
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if tutorialNum == 3 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .frame(width: buttonRect3.width, height: buttonRect3.height)
                                        .position(x: buttonRect3.midX, y: buttonRect3.midY)
                                        .blendMode(.destinationOut)
                                )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                                .onTapGesture{
                                    audioManager.playSound()
                                    tutorialNum = 4 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                                    }
                                }
                        }
                        VStack {
                            Spacer()
                                .frame(height: buttonRect3.minY + bubbleHeight3-40)
                            VStack(alignment: .trailing, spacing: .zero) {
                                
                                //                        Image("上矢印")
                                //                            .resizable()
                                //                            .frame(width: 20, height: 20)
                                //                            .padding(.trailing, isSmallDevice() ? 300 : 330)
                                Text("こちらは親密度です。\n会話をすると上がっていき、新しいエリアが解放されることがあります。")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .background(GeometryReader { geometry in
                                Path { _ in
                                    DispatchQueue.main.async {
                                        self.bubbleHeight3 = geometry.size.height
                                    }
                                }
                            })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 4 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                            }
                        }
                        VStack{
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if tutorialNum == 4 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .frame(width: buttonRect4.width, height: buttonRect4.height)
                                        .position(x: buttonRect4.midX, y: buttonRect4.midY)
                                        .blendMode(.destinationOut)
                                )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                                .onTapGesture{
                                    audioManager.playSound()
                                    tutorialNum = 5 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                                    }
                                }
                        }
                        VStack {
                            Spacer()
                                .frame(height: isSmallDevice() ?  buttonRect4.minY + bubbleHeight4 - 10 : buttonRect4.minY + bubbleHeight4 - 15 )
                            VStack(alignment: .trailing, spacing: .zero) {
                                
                                //                        Image("上矢印")
                                //                            .resizable()
                                //                            .frame(width: 20, height: 20)
                                //                            .padding(.trailing, 180)
                                Text("こちらはコインです。\nおともと会話する度に１コイン減ります。")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .background(GeometryReader { geometry in
                                Path { _ in
                                    DispatchQueue.main.async {
                                        self.bubbleHeight4 = geometry.size.height
                                    }
                                }
                            })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 5 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                            }
                        }
                        VStack{
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if tutorialNum == 5 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .frame(width: buttonRect5.width, height: buttonRect5.height)
                                        .position(x: buttonRect5.midX, y: buttonRect5.midY)
                                        .blendMode(.destinationOut)
                                )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                                .onTapGesture{
                                    audioManager.playSound()
                                    tutorialNum = 6 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                                    }
                                }
                        }
                        VStack {
                            Spacer()
                                .frame(height: buttonRect5.minY - 140)
                            VStack(alignment: .trailing, spacing: .zero) {
                                Text("おともとのやりとりが見れます。\n\nユーザーのアイコンをクリックするとプロフィールを編集することもできます。")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                                    .onTapGesture{
                                        audioManager.playSound()
                                        tutorialNum = 6 // タップでチュートリアルを終了
                                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                                        }
                                    }
                            }
                            .background(GeometryReader { geometry in
                                Path { _ in
                                    DispatchQueue.main.async {
                                        self.bubbleHeight5 = geometry.size.height
                                    }
                                }
                            })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 5 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                            }
                        }
                        VStack{
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if tutorialNum == 6 {
                        GeometryReader { geometry in
                            Color.black.opacity(0.5)
                            // スポットライトの領域をカットアウ
                            //                            .overlay(
                            //                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                            //                                    .frame(width: buttonRect4.width, height: buttonRect4.height)
                            //                                    .position(x: buttonRect4.midX, y: buttonRect4.midY)
                            //                                    .blendMode(.destinationOut)
                            //                            )
                                .ignoresSafeArea()
                                .compositingGroup()
                                .background(.clear)
                                .onTapGesture{
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }
                        }
                        VStack {
                            Spacer()
                            //                            .frame(height: buttonRect4.minY + bubbleHeight4 - 70)
                            VStack(alignment: .trailing, spacing: .zero) {
                                
                                //                        Image("上矢印")
                                //                            .resizable()
                                //                            .frame(width: 20, height: 20)
                                //                            .padding(.trailing, 180)
                                Text("他にも各エリアごとにお宝があるので、集めてフルコンプを目指しましょう。\n\nそれではおともとの楽しい会話をお楽しみください！")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
                                    .padding(.all, 16.0)
                                    .background(Color("background"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            //                        .background(GeometryReader { geometry in
                            //                            Path { _ in
                            //                                DispatchQueue.main.async {
                            //                                    self.bubbleHeight4 = geometry.size.height
                            //                                }
                            //                            }
                            //                        })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .onTapGesture{
                            audioManager.playSound()
                            tutorialNum = 7 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                            }
                        }
                        VStack{
                            HStack{
                                Button(action: {
                                    audioManager.playSound()
                                    tutorialNum = 7 // タップでチュートリアルを終了
                                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                    }
                                }) {
                                    Image("スキップ")
                                        .resizable()
                                        .frame(width:200,height:40)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    if flag1 == true {
                        ModalTreasureView(showLevelUpModal: $flag1, authManager: authManager, treasureNumber: .constant(1))
                    }
                    if flag2 == true {
                        ModalTreasureView(showLevelUpModal: $flag2, authManager: authManager, treasureNumber: .constant(2))
                    }
                    if flag3 == true {
                        ModalTreasureView(showLevelUpModal: $flag3, authManager: authManager, treasureNumber: .constant(3))
                    }
                    if flag4 == true {
                        ModalTreasureView(showLevelUpModal: $flag4, authManager: authManager, treasureNumber: .constant(4))
                    }
                    if flag5 == true {
                        ModalTreasureView(showLevelUpModal: $flag5, authManager: authManager, treasureNumber: .constant(5))
                    }
                    if flag6 == true {
                        ModalTreasureView(showLevelUpModal: $flag6, authManager: authManager, treasureNumber: .constant(6))
                    }
                    if flag7 == true {
                        ModalTreasureView(showLevelUpModal: $flag7, authManager: authManager, treasureNumber: .constant(7))
                    }
                    if flag8 == true {
                        ModalTreasureView(showLevelUpModal: $flag8, authManager: authManager, treasureNumber: .constant(8))
                    }
                    if flag9 == true {
                        ModalTreasureView(showLevelUpModal: $flag9, authManager: authManager, treasureNumber: .constant(9))
                    }
                    if flag10 == true {
                        ModalTreasureView(showLevelUpModal: $flag10, authManager: authManager, treasureNumber: .constant(10))
                    }
                    if flag11 == true {
                        ModalTreasureView(showLevelUpModal: $flag11, authManager: authManager, treasureNumber: .constant(11))
                    }
                    if flag12 == true {
                        ModalTreasureView(showLevelUpModal: $flag12, authManager: authManager, treasureNumber: .constant(12))
                    }
                    if flag13 == true {
                        ModalTreasureView(showLevelUpModal: $flag13, authManager: authManager, treasureNumber: .constant(13))
                    }
                    if flag14 == true {
                        ModalTreasureView(showLevelUpModal: $flag14, authManager: authManager, treasureNumber: .constant(14))
                    }
                    if flag15 == true {
                        ModalTreasureView(showLevelUpModal: $flag15, authManager: authManager, treasureNumber: .constant(15))
                    }
                    if backgroundFlag1 == true {
                        ModalBackgroundView(showLevelUpModal: $backgroundFlag1, authManager: authManager, backgroundNumber: .constant(1))
                    }
                    if backgroundFlag2 == true {
                        ModalBackgroundView(showLevelUpModal: $backgroundFlag2, authManager: authManager, backgroundNumber: .constant(2))
                    }
                    if backgroundFlag3 == true {
                        ModalBackgroundView(showLevelUpModal: $backgroundFlag3, authManager: authManager, backgroundNumber: .constant(3))
                    }
                    if backgroundFlag4 == true {
                        ModalBackgroundView(showLevelUpModal: $backgroundFlag4, authManager: authManager, backgroundNumber: .constant(4))
                    }
                    if csFlag == true {
                        HelpModalView(audioManager: AudioManager(), isPresented: $csFlag)
                    }
                    
                    if nameModalFlag == true {
                        ZStack {
                            Color.black.opacity(0.7)
                                .edgesIgnoringSafeArea(.all)
                            NameUpdateModalView(audioManager: audioManager, isPresented: $nameModalFlag)
                        }
                    }
                    if showUnCoinModal {
                        ZStack {
                            Color.black.opacity(0.7)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack{
                                ScrollView{
                                    VStack{
                                        HStack{
                                            Image("コインが無い")
                                                .resizable()
                                                .frame(width:70,height: 70)
                                            VStack(alignment: .leading, spacing:15){
                                                HStack{
                                                    Text("コインが足りません")
                                                    Spacer()
                                                }
                                                Text("ご購入することもできます")
                                                    .font(.system(size: isSmallDevice() ? 17 : 18))
                                            }
                                            
                                        }.padding()
                                    }.frame(width: isSmallDevice() ? 330: 340, height:120)
                                        .background(Color("background"))
                                        .font(.system(size: 20))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 15)
                                        )
                                        .cornerRadius(20)
                                        .shadow(radius: 10)
                                    CoinModalView(audioManager: audioManager, isPresented: $showUnCoinModal)
                                }
                            }
                            
                        }
                        .onTapGesture{
                            showUnCoinModal = false
                        }
                        
                    }
                    
                    if showCoinModal {
                        ZStack {
                            Color.black.opacity(0.7)
                                .edgesIgnoringSafeArea(.all)
                            CoinModalView(audioManager: audioManager, isPresented: $showCoinModal)
                        }
                    }
                }
            }
            .foregroundColor(Color("fontGray"))
            .frame(maxHeight:.infinity)
            .background(Color("background"))
            .onChange(of: chat.last?.role) { _ in
                authManager.fetchCoinCount()
            }
            // 画面をタップしたときにキーボードを閉じる
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .background {
                    // Add the adViewControllerRepresentable to the background so it
                    // doesn't influence the placement of other views in the view hierarchy.
                    adViewControllerRepresentable
                      .frame(width: .zero, height: .zero)
                  }
            .onChange(of: interstitial.interstitialAdLoaded) { isLoaded in
                if isLoaded && !interstitial.wasAdDismissed && authManager.userPreFlag != 1 {
                      interstitial.presentInterstitial()
                  }
              }
            .onAppear{
                if let userId = authManager.currentUserId {
                    authManager.loadRecentMessages(userId: userId) { messages in
                        let contents = messages.compactMap { $0.content }
                        
                        self.updateChatWithSystemMessage(contents)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fetchUserTreasures(userId: authManager.currentUserId!)
                    
                }
                authManager.fetchPreFlag()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if userFlag == 0 {
                        executeProcessEveryThreeTimes()
                    }
                }
                // コメントを送信したら背景追加できるようにする
                authManager.fetchAvatars {
                    if let firstAvatar = authManager.avatars.first, firstAvatar.heart >= 300 {
                        print("onChange")
                        authManager.addBackgroundToUser(backgroundName: "背景2") { success in
                            if success {
                                backgroundFlag1 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                    if let firstAvatar = authManager.avatars.first, firstAvatar.heart >= 500 {
                        print("onChange")
                        authManager.addBackgroundToUser(backgroundName: "背景3") { success in
                            if success {
                                backgroundFlag2 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                    if let firstAvatar = authManager.avatars.first, firstAvatar.heart >= 800 {
                        print("onChange")
                        authManager.addBackgroundToUser(backgroundName: "背景4") { success in
                            if success {
                                backgroundFlag3 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                    if let firstAvatar = authManager.avatars.first, firstAvatar.heart >= 1000 {
                        print("onChange")
                        authManager.addBackgroundToUser(backgroundName: "背景5") { success in
                            if success {
                                backgroundFlag4 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                }
                authManager.updateCoinCountBasedOnLastLogin(userId: authManager.currentUserId!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    authManager.saveLastLoginDate(userId: authManager.currentUserId!){ success in
                    }
                }
                authManager.fetchCoinCount()
                authManager.fetchUserProf()
                authManager.fetchUsedAvatars() { success in
                }
                authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                    self.userName = name ?? ""
                    self.avatar = avatar ?? [[String: Any]]()
                    self.userMoney = money ?? 0
                    self.userHp = hp ?? 100
                    self.userAttack = attack ?? 20
                    self.tutorialNum = tutorialNum ?? 0
                    self.userFlag = userFlag ?? 0
                    tutorialStart = true
                    if tutorialStart && tutorialNum == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            authManager.fetchUsedBackgrounds { usedBackgrounds in
                            }
                        }
                    } else {
                        authManager.fetchUsedBackgrounds { usedBackgrounds in
                        }
                    }
                    authManager.level = self.userLevel
                    authManager.money = self.userMoney
                    authManager.usedAvatarHeart = self.avatar.first?["heart"] as! Int
                    print("avatarHeart:\(avatarHeart)")
                    if avatarHeart >= 300 {
                        authManager.addBackgroundToUser(backgroundName: "背景2") { success in
                            if success {
                                backgroundFlag1 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                    
                    if avatarHeart >= 500 {
                        authManager.addBackgroundToUser(backgroundName: "背景3") { success in
                            if success {
                                backgroundFlag2 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                    
                    if avatarHeart >= 800 {
                        authManager.addBackgroundToUser(backgroundName: "背景4") { success in
                            if success {
                                backgroundFlag3 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                    
                    if avatarHeart >= 1000 {
                        authManager.addBackgroundToUser(backgroundName: "背景5") { success in
                            if success {
                                backgroundFlag4 = true
                                print("背景が正常に追加されました。4")
                            } else {
                                print("背景の追加に失敗しました。")
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func executeProcessEveryThreeTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchCount")
        
        // 3回に1回の割合で処理を実行
        if count % 5 == 0 {
            csFlag = true
        }
    }
    
    func executeProcessEveryTenTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchCount")
        
        // 10回に1回の割合で処理を実行
        if count % 3 == 0 {
            interstitial.loadInterstitial()
            interstitial.wasAdDismissed = false
        }
    }
    
    func fetchUserTreasures(userId: String) {
        let treasuresRef = Database.database().reference().child("treasures").child(userId)
        treasuresRef.observeSingleEvent(of: .value) { snapshot in
            if let treasures = snapshot.value as? [String: Bool] {
                self.userTreasures = treasures
            }
        }
    }
    
    func updateChatWithSystemMessage(_ contents: [String]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    print("authManager.userProf@@@@@@@:\(authManager.userProf)")
                    let joinedContents = contents.joined(separator: ", ")
                    let systemMessage = authManager.usedAvatarSystem + "相手の名前は\(self.userName)と呼びます。\(authManager.userProf)がユーザーの趣味・興味があるもので\(joinedContents)が直近のユーザーの10件のメッセージです。そちらも考慮して回答してください。"
                    self.chat.insert(ChatMessage(role: .system, content: systemMessage), at: 0)
                    print("systemMessage:\(systemMessage)")
                    print("chat@@@@:\(chat)")
            }
        }
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
    
    
//    ContentView()
    TopView()
}
