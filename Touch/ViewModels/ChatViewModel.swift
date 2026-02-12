import Foundation
import SwiftUI

@Observable
class ChatViewModel {
    var chats: [Chat] = []

    func createChat(contactName: String) {
        let chat = Chat(contactName: contactName)
        chats.insert(chat, at: 0)
    }

    func sendMessage(to chatID: UUID, text: String) {
        guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
        let message = Message(text: text, isFromMe: true)
        chats[index].messages.append(message)
    }

    func deleteChat(at offsets: IndexSet) {
        chats.remove(atOffsets: offsets)
    }

    var sortedChats: [Chat] {
        chats.sorted { $0.lastMessageDate > $1.lastMessageDate }
    }
}
