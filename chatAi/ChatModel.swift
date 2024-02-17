////
////  ChatModel.swift
////  chatAi
////
////  Created by Apple on 2024/02/15.
////
//
//import SwiftUI
//import Foundation
//
//struct ChatMessage: Identifiable {
//    let id: UUID = UUID()
//    let message: String
//    let isUser: Bool
//}
//
//class ChatModel: ObservableObject {
//    @Published var messages: [ChatMessage] = []
//
//    func sendMessage(_ message: String) {
//        let userMessage = ChatMessage(message: message, isUser: true)
//        self.messages.append(userMessage)
//        
//        getAIResponse(message)
//    }
//
//    private func getAIResponse(_ message: String) {
//        let apiKey = "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"
//        let url = URL(string: "https://api.openai.com/v1/engines/text-davinci-002/completions")!
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let body: [String: Any] = [
//            "prompt": message,
//            "max_tokens": 60
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("APIリクエストエラー: \(error.localizedDescription)")
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("APIリクエスト失敗: ステータスコード非200")
//                return
//            }
//            if let data = data {
//                if let decodedResponse = try? JSONDecoder().decode(AIResponse.self, from: data) {
//                    DispatchQueue.main.async {
//                        let aiMessage = ChatMessage(message: decodedResponse.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", isUser: false)
//                        self.messages.append(aiMessage)
//                    }
//                } else {
//                    print("デコード失敗")
//                }
//            }
//        }.resume()
//
//    }
//}
//
//struct AIResponse: Codable {
//    struct Choice: Codable {
//        let text: String
//    }
//    let choices: [Choice]
//}
