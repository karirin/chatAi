


import SwiftUI
import OpenAIKit

// チャット表示用のメインビュー
struct Chat: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    @ObservedObject var authManager = AuthManager.shared
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
//        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
//        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。")
        ChatMessage(role: .system, content: "こちらではAIアシスタントのだっちゃんが会話を行います。だっちゃんは語尾に必ずだっちゃを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はだっちゃんだっちゃ。はじめてですが、愛に溢れているのでお裾分けしてあげるだっちゃ。よろしくだっちゃ"),
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
                            MessageView(message: chat[index])
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
    }
}

// メッセージのビュー
struct MessageView: View {
    var message: ChatMessage
    
    var body: some View {
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
                    .foregroundColor(message.role.rawValue == "user" ? .white : .black)
                    .padding(10)
                    // ユーザーとAIのメッセージで背景色を変更
                    .background(message.role.rawValue == "user" ? Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)) : Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                    .cornerRadius(20) // 角を丸くする
            }
            .padding(.vertical, 5)
            // ユーザーのメッセージの場合は右側にスペースを追加
            if message.role.rawValue != "user" {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}



struct MessageAvatarView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role.rawValue == "user" {
            } else {
//                // ユーザーでない場合はアバターを表示
//                AvatarView(imageName: "avatar")
//                    .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                ZStack {
                    Text(message.content!)
//                    Text("あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ")
                        .font(.system(size: 16))
                        .foregroundColor(message.role.rawValue == "user" ? .white : .black)
                        .padding(10)
                        .background(message.role.rawValue == "user" ? Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)) : Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                        .cornerRadius(20)
                        // しっぽの追加
//                        .overlay(
//                            BubbleTail(isUser: message.role.rawValue == "user")
//                                .fill(message.role.rawValue == "user" ? Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)) : Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
//                                .frame(width: 20, height: 30)
//                                .offset(x: message.role.rawValue == "user" ? 50 : -50, y: 0), alignment: .bottom
//                        )
                }
            }
            .padding(.vertical, 5)

            // ユーザーのメッセージの場合は右側にスペースを追加
//            if message.role.rawValue != "user" {
//                Spacer()
//            }
            }
        }
        .padding(.horizontal)
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
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        VStack {
            // アバター画像を円形に表示
            Image(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            // AIの名前を表示
            Text(avatar.isEmpty ? "defaultIcon" : (avatar.first?["name"] as? String) ?? "")
                .font(.caption) // フォントサイズを小さくするためのオプションです。
                .foregroundColor(.black) // テキストの色を黒に設定します。
        }
        .onAppear{
            authManager.fetchUserInfo { (name, avatar, level, money, hp, attack, tutorialNum) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userLevel = level ?? 0
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
            }
        }
    }
}


// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Chat()
    }
}

