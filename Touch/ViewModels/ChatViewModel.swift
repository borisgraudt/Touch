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

    func deleteChat(id: UUID) {
        chats.removeAll { $0.id == id }
    }

    func deleteChat(at offsets: IndexSet) {
        chats.remove(atOffsets: offsets)
    }

    func toggleMute(id: UUID) {
        guard let index = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[index].isMuted.toggle()
    }

    func togglePin(id: UUID) {
        guard let index = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[index].isPinned.toggle()
    }

    var sortedChats: [Chat] {
        let pinned = chats.filter { $0.isPinned }.sorted { $0.lastMessageDate > $1.lastMessageDate }
        let unpinned = chats.filter { !$0.isPinned }.sorted { $0.lastMessageDate > $1.lastMessageDate }
        return pinned + unpinned
    }
}
