//
//  ChatHistoryView.swift
//  chatAi
//
//  Created by Apple on 2024/02/17.
//

import SwiftUI
import OpenAIKit

struct ChatHistoryView: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    @State private var loadedMessages: [ChatMessage] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showUnCoinModal = false
    @State private var userMoney: Int = 0
    @State private var userLevel: Int = 0
    @State private var userHp: Int = 100
    @State private var userFlag: Int = 0
    @State private var userAttack: Int = 20
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var tutorialNum: Int = 0
    @ObservedObject var audioManager = AudioManager.shared
    @State private var showCoinModal = false
    @State private var nameModalFlag = false
    @ObservedObject var interstitial = Interstitial()
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @State private var chat: [ChatMessage] = [

        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
        ZStack{
            VStack {
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
                }
                    
                }.padding(.horizontal)
                    .padding(.top,10)
                // スクロール可能なメッセージリストの表示
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(loadedMessages.indices, id: \.self) { index in
                                MessageView(message: loadedMessages[index],nameModalFlag: $nameModalFlag, audioManager: audioManager)
                                
                            }
                        }
                    }
                    .onChange(of: loadedMessages.count) { _ in
                        // メッセージの数が変わるたびに最下部にスクロール
                        if let lastMessageIndex = loadedMessages.indices.last {
                            scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        if let userId = authManager.currentUserId {
                            authManager.loadMessages(userId: userId) { messages in
                                self.loadedMessages = messages
                                print("self.loadedMessages:\(self.loadedMessages)")
                                // メッセージの読み込み後、最下部にスクロール
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 0.1秒後に実行
                                    if let lastMessageIndex = loadedMessages.indices.last {
                                        scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                // 画面をタップしたときにキーボードを閉じる
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
                if authManager.userPreFlag != 1 {
                    BannerView()
                        .frame(height:40)
                }
                // テキスト入力フィールドと送信ボタンの表示
                HStack {
                    
                    // テキスト入力フィールド
                    TextField("メッセージを入力", text: $text)
                    //                    .focused($isTextFieldFocused)
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
                .padding(.bottom,8)
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
        .foregroundColor(Color("fontGray"))
        .background(Color("background"))
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
        .onAppear {
            if let userId = authManager.currentUserId {
                authManager.loadRecentMessages(userId: userId) { messages in
                    let contents = messages.compactMap { $0.content }
                    
                    self.updateChatWithSystemMessage(contents)
                }
            }
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
                self.userFlag = userFlag ?? 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("authManager.userPreFlag:\(authManager.userPreFlag)")
            }
                authManager.fetchPreFlag()
            }
            .background(Color("background"))
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                Text("戻る")
                    .foregroundColor(Color("fontGray"))
            })
            .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("会話履歴")
                            .font(.system(size: 20)) // ここでフォントサイズを指定
                            .foregroundColor(Color("fontGray"))
                    }
                }

    }
    
    func executeProcessEveryTenTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "launchCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "launchCount")
        
        // 10回に1回の割合で処理を実行
        if count % 3 == 0 {
//            adFlag = true
            interstitial.loadInterstitial()
            interstitial.wasAdDismissed = false
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    func updateChatWithSystemMessage(_ contents: [String]) {
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                   DispatchQueue.main.async {
                       let joinedContents = contents.joined(separator: ", ")
                       let systemMessage = authManager.usedAvatarSystem + "相手の名前は\(self.userName)と呼びます。\(joinedContents)が直近のユーザーの10件のメッセージです。そちらも考慮して回答してください。"
                       self.chat.insert(ChatMessage(role: .system, content: systemMessage), at: 0)
                       print("chat@@@@:\(chat)")
               }
           }
           }
}

struct ChatHistoryTopView: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    @State private var loadedMessages: [ChatMessage] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager:AudioManager
    @State private var nameModalFlag = false
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。"),
        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はライムだライム。はじめてですが、愛に溢れているのでお裾分けしてあげるライム。よろしくライム"),
        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
            VStack {
                // スクロール可能なメッセージリストの表示
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
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
                    .onChange(of: loadedMessages.count) { _ in
                        // メッセージの数が変わるたびに最下部にスクロール
                        if let lastMessageIndex = loadedMessages.indices.last {
                            scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        if let userId = authManager.currentUserId {
                            authManager.loadMessages(userId: userId) { messages in
                                self.loadedMessages = messages
                                // メッセージの読み込み後、最下部にスクロール
                                if let lastMessageIndex = loadedMessages.indices.last {
                                    scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                .padding(.top)
                // 画面をタップしたときにキーボードを閉じる
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
                // テキスト入力フィールドと送信ボタンの表示
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
//                    Button(action: {
//                        isCompleting = true
//                        // ユーザーのメッセージをチャットに追加
//                        chat.append(ChatMessage(role: .user, content: text))
//                        text = "" // テキストフィールドをクリア
//                        authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
//                        if let userId = authManager.currentUserId {
//                            authManager.addHeartToAvatar(userId: userId, additionalHeart: 5) { success in
//                                if success {
//                                    print("Heart added successfully.")
//                                } else {
//                                    print("Failed to add heart.")
//                                }
//                            }
//                        }
//                        Task {
//                            do {
//                                // OpenAIの設定
//
//                                )
//                                let openAI = OpenAI(config)
//                                let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-3.5-turbo")!, messages: chat)
//                                
//                                // チャットの生成
//                                let chatCompletion = try await openAI.generateChatCompletion(
//                                    parameters: chatParameters
//                                )
//                                
//                                isCompleting = false
//                                // AIのレスポンスをチャットに追加
//                                chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message?.content))
//                            } catch {
//                                print("ERROR DETAILS - \(error)")
//                            }
//                        }
//                    }) {
//                        // 送信ボタンのデザイン
//                        Image(systemName: "arrow.up.circle.fill")
//                            .font(.system(size: 30))
//                            .foregroundColor(self.text == "" ? Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.8, alpha: 1)) : Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
//                    }
//                    // テキストが空またはチャットが完了していない場合はボタンを無効化
//                    .disabled(self.text == "" || isCompleting)
                    
                    // 送信ボタン
                    Button(action: {
                        // ボタンが押されたことを示すフラグをセット
                        isCompleting = true
                        
                        // 送信するメッセージを作成
                        let newMessage = ChatMessage(role: .user, content: text)
                        
                        // テキストフィールドをクリア
                        text = ""
                        
                        // メッセージをFirebaseに保存
                        authManager.saveMessage(userId: authManager.currentUserId!, message: newMessage)
                        print("test3")
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
                               //ここ
                                let openAI = OpenAI(config)
                                let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-4")!, messages: chat + [newMessage])
                                
                                // チャットの生成
                                let chatCompletion = try await openAI.generateChatCompletion(
                                    parameters: chatParameters
                                )
                                
                                // AIのレスポンスをチャットに追加
                                DispatchQueue.main.async {
                                    chat.append(newMessage)
                                    print("sss")
                                    chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message?.content))
                                    authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                                    print("test4")
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
                    }) {
                        // 送信ボタンのデザイン
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(self.text == "" ? Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.8, alpha: 1)) : Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                    }
                    // テキストが空またはチャットが完了していない場合はボタンを無効化
                    .disabled(self.text == "" || isCompleting)
                    .onChange(of: chat.last?.role) { lastMessage in
                        print("test5")
//                        authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16) // 下部のパディングを調整
            }
            .background(Color("background"))
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action: {
//                self.presentationMode.wrappedValue.dismiss()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.gray)
//                Text("戻る")
//                    .foregroundColor(Color("fontGray"))
//            })
//            .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text("会話履歴")
//                            .font(.system(size: 20)) // ここでフォントサイズを指定
//                            .foregroundColor(Color("fontGray"))
//                    }
//                }
    }
}

struct ChatHistoryNotBtnView: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    @State private var loadedMessages: [ChatMessage] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    @State private var showUnCoinModal = false
    @State private var nameModalFlag = false
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。"),
        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
//        ChatMessage(role: .assistant, content: "私の名前はライムだライム。はじめてですが、愛に溢れているのでお裾分けしてあげるライム。よろしくライム"),
//        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
        ZStack{
            // スクロール可能なメッセージリストの表示
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading) {
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
                .onChange(of: loadedMessages.count) { _ in
                    // メッセージの数が変わるたびに最下部にスクロール
                    if let lastMessageIndex = loadedMessages.indices.last {
                        scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                    }
                }
                .onAppear {
                    if let userId = authManager.currentUserId {
                        authManager.loadMessages(userId: userId) { messages in
                            self.loadedMessages = messages
                        }
                    }
                    if let userId = authManager.currentUserId {
                        authManager.loadMessages(userId: userId) { messages in
                            self.loadedMessages = messages
                            // メッセージの読み込み後、最下部にスクロール
                            if let lastMessageIndex = loadedMessages.indices.last {
                                scrollViewProxy.scrollTo(lastMessageIndex, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        // 画面をタップしたときにキーボードを閉じる
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
                // テキスト入力フィールドと送信ボタンの表示
//                HStack {
//                    // テキスト入力フィールド
//                    TextField("メッセージを入力", text: $text)
//                        .disabled(isCompleting) // チャットが完了するまで入力を無効化
//                        .font(.system(size: 15)) // フォントサイズを調整
//                        .padding(8)
//                        .padding(.horizontal, 10)
//                        .background(Color.white) // 入力フィールドの背景色を白に設定
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
//                            
//                        )
//                    
//                    // 送信ボタン
//                    Button(action: {
//                        // ボタンが押されたことを示すフラグをセット
//                        isCompleting = true
//                        
//                        // 送信するメッセージを作成
//                        let newMessage = ChatMessage(role: .user, content: text)
//                        
//                        // テキストフィールドをクリア
//                        text = ""
//                        
//                        // メッセージをFirebaseに保存
//                        authManager.saveMessage(userId: authManager.currentUserId!, message: newMessage)
//                        
//                        Task {
//                            do {
//                                // OpenAIの設定
//                                
//                                let openAI = OpenAI(config)
//                                let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-3.5-turbo")!, messages: chat + [newMessage])
//                                
//                                // チャットの生成
//                                let chatCompletion = try await openAI.generateChatCompletion(
//                                    parameters: chatParameters
//                                )
//                                
//                                // AIのレスポンスをチャットに追加
//                                DispatchQueue.main.async {
//                                    chat.append(newMessage)
//                                    chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message?.content))
//                                    authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
//                                    print("``````````````")
//                                    // 処理が完了したのでフラグをクリア
//                                    isCompleting = false
//                                }
//                            } catch {
//                                DispatchQueue.main.async {
//                                    // エラーが発生した場合の処理
//                                    print("ERROR DETAILS - \(error)")
//                                    // 処理が完了したのでフラグをクリア
//                                    isCompleting = false
//                                }
//                            }
//                        }
//                    }) {
//                        // 送信ボタンのデザイン
//                        Image(systemName: "arrow.up.circle.fill")
//                            .font(.system(size: 30))
//                            .foregroundColor(self.text == "" ? Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.8, alpha: 1)) : Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
//                    }
//                    // テキストが空またはチャットが完了していない場合はボタンを無効化
//                    .disabled(self.text == "" || isCompleting)
//                    .onChange(of: chat.last?.role) { lastMessage in
//                        authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 8) // 下部のパディングを調整
            }
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: Button(action: {
//                self.presentationMode.wrappedValue.dismiss()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.gray)
//                Text("戻る")
//                    .foregroundColor(Color("fontGray"))
//            })
//            .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text("会話履歴")
//                            .font(.system(size: 20)) // ここでフォントサイズを指定
//                            .foregroundColor(Color("fontGray"))
//                    }
//                }
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    ChatHistoryView()
//    TopView()
}
