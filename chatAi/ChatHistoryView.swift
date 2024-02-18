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
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
//        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
//        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。")
        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はライムだライム。はじめてですが、愛に溢れているのでお裾分けしてあげるライム。よろしくライム"),
//        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
            VStack {
                // スクロール可能なメッセージリストの表示
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(loadedMessages.indices, id: \.self) { index in
                                MessageView(message: loadedMessages[index])
                                
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
                        // ボタンが押されたことを示すフラグをセット
                        isCompleting = true
                        
                        // 送信するメッセージを作成
                        let newMessage = ChatMessage(role: .user, content: text)
                        
                        // テキストフィールドをクリア
                        text = ""
                        
                        // メッセージをFirebaseに保存
                        authManager.saveMessage(userId: authManager.currentUserId!, message: newMessage)
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
                                let chatParameters = ChatParameters(model: ChatModels(rawValue: "gpt-3.5-turbo")!, messages: chat + [newMessage])
                                
                                // チャットの生成
                                let chatCompletion = try await openAI.generateChatCompletion(
                                    parameters: chatParameters
                                )
                                
                                // AIのレスポンスをチャットに追加
                                DispatchQueue.main.async {
                                    chat.append(newMessage)
                                    chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message?.content))
                                    authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                                    print("``````````````")
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
                        authManager.saveMessage(userId: authManager.currentUserId!, message: chat.last!)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8) // 下部のパディングを調整
            }
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
}

struct ChatHistoryNotBtnView: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    @State private var loadedMessages: [ChatMessage] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
//        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
//        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。")
        ChatMessage(role: .system, content: "こちらではAIアシスタントのライムが会話を行います。ライムは語尾に必ずライムを付けます。可愛くて愛情たっぷりな表現をするのが得意です。"),
        ChatMessage(role: .assistant, content: "私の名前はライムだライム。はじめてですが、愛に溢れているのでお裾分けしてあげるライム。よろしくライム"),
//        ChatMessage(role: .user, content: "これからよろしくね！会話を楽しもう！")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
                // スクロール可能なメッセージリストの表示
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(loadedMessages.indices, id: \.self) { index in
                                MessageView(message: loadedMessages[index])
                                
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
//                                let config = Configuration(
//                                    organizationId: "org-dPUAuIy1CBxghho0gfTEk53n",
//                                    apiKey: "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"
//                                )
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
}

#Preview {
    ChatHistoryView()
}
