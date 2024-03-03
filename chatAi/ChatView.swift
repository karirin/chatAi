


import SwiftUI
import OpenAIKit

// チャット表示用のメインビュー
struct Chat: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager:AudioManager
    @State private var nameModalFlag = false
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。"),
        ChatMessage(role: .system, content: "こちらではAIアシスタントのだっちゃんが会話を行います。だっちゃんは語尾に必ずだっちゃを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
//        ChatMessage(role: .assistant, content: "私の名前はだっちゃんだっちゃ。はじめてですが、愛に溢れているのでお裾分けしてあげるだっちゃ。よろしくだっちゃ"),
//        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
        VStack {
            // スクロール可能なメッセージリストの表示
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chat.indices, id: \.self) { index in
                        // 最初のメッセージ以外を表示
                        if index > 1 {
                            MessageView(message: chat[index],nameModalFlag: $nameModalFlag, audioManager: audioManager)
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
                
                // 送信ボタン
                Button(action: {
                    isCompleting = true
                    // ユーザーのメッセージをチャットに追加
                    chat.append(ChatMessage(role: .user, content: text))
                    text = "" // テキストフィールドをクリア
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
                            let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-4")!, messages: chat)
                            
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
    }
}

// メッセージのビュー
struct MessageView: View {
    var message: ChatMessage
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userLevel: Int = 0
    @State private var userHp: Int = 100
    @State private var userFlag: Int = 0
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @Binding var nameModalFlag: Bool
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var audioManager:AudioManager
    
    var body: some View {
        ZStack{
            HStack {
                if message.role.rawValue == "user" {
                    Spacer()
                } else {
                    // ユーザーでない場合はアバターを表示
                    AvatarView(imageName: "avatar")
                        .padding(.trailing, 8)
                }
                VStack(alignment: .leading, spacing: 4) {
                    // メッセージのテキストを表示
                    Text(message.content!)
                        .font(.system(size: 14)) // フォントサイズを調整
                        .foregroundColor(message.role.rawValue == "user" ? .black : .black)
                        .padding(10)
                    
                        .background(message.role.rawValue == "user" ? Color("chatUserColor") : Color("chatColor"))
                        .cornerRadius(20) // 角を丸くする
                }
                .padding(.vertical, 5)
                // ユーザーのメッセージの場合は右側にスペースを追加
                if message.role.rawValue == "user" {
                    VStack{
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(userName)
                            .font(.caption)
                            .foregroundColor(.black)
                    }.padding(.top,5)
                        .onTapGesture {
                            nameModalFlag = true
                        }
                }
            }
        }
        .onChange(of: nameModalFlag) { _ in
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
                self.userFlag = userFlag ?? 0
            }
        }
        .onAppear{
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
                self.userFlag = userFlag ?? 0
            }
        }
        .padding(.horizontal)
    }
}



struct MessageAvatarView: View {
    var message: ChatMessage
    @ObservedObject var authManager = AuthManager.shared
    @State var tutorialNum: Int
    @Binding var tutorialStart: Bool
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userFlag: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 20
    @State private var isLoading: Bool = true
    @Binding var chatFlag: Bool
    
    var body: some View {
        HStack {
            if chatFlag == true {
                Text("えへへ、撫でてくれてありがとう♪\n\(userName)ともっとお話ししたいな♪♪")
                    .padding(10)
                    .background(Color("chatColor"))
                    .cornerRadius(20)
            } else {
                //                Text("ss")
                
                if message.role.rawValue == "user" {
                    if tutorialNum == 0 && tutorialStart {
                        Text("はじめまして！\(self.userName)！\(authManager.usedAvatarName)だよ♪\n雑談、悩み、恋話、なんでも話してね♪♪")
                            .padding(10)
                            .background(Color("chatColor"))
                            .cornerRadius(20)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.content!)
//                        Text("ああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ")
                            .font(.system(size: fontSize(for: message.content!, isIPad: isIPad())))
                            .foregroundColor(message.role.rawValue == "user" ? .black : .black)
                            .padding(10)
                            .background(message.role.rawValue == "user" ? Color("chatUserColor") : Color("chatColor"))
                            .cornerRadius(20)
                    }
                    .padding(.vertical, 5)
                    .padding(.top)
                }
            }
            }
        .onAppear{
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
                self.userFlag = userFlag ?? 0
                self.isLoading = false
            }
        }
        .onChange(of: message.content) { _ in
                                print("message.content:\(message.content)")
                            }
        .padding(.horizontal)
        }
        // テキストサイズを決定する関数
        func fontSize(for text: String, isIPad: Bool) -> CGFloat {
            let baseFontSize: CGFloat = isIPad ? 24 : 20 // iPad用のベースフォントサイズを大きくする

            let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let textCharacterSet = CharacterSet(charactersIn: text)

            if englishAlphabet.isSuperset(of: textCharacterSet) {
                return baseFontSize
            } else {
                if text.count >= 25 {
                    return baseFontSize - 6
                } else if text.count >= 21 {
                    return baseFontSize - 6
                } else if text.count >= 17 {
                    return baseFontSize - 6
                } else {
                    return baseFontSize - 4
                }
            }
        }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    }


// アバタービュー
struct AvatarView: View {
    var imageName: String
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userLevel: Int = 0
    @State private var userHp: Int = 100
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @State private var userFlag: Int = 0
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        VStack {
            // アバター画像を円形に表示
            Image(avatar.isEmpty ? "" : (avatar.first?["name"] as? String) ?? "")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            // AIの名前を表示
            Text(avatar.isEmpty ? "" : (avatar.first?["name"] as? String) ?? "")
                .font(.caption) // フォントサイズを小さくするためのオプションです。
                .foregroundColor(.black) // テキストの色を黒に設定します。
        }
        .onAppear{
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
                self.userFlag = userFlag ?? 0
            }
        }
    }
}


// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        Chat()
        TopView()
    }
}

