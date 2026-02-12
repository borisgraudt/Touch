import Foundation
import SwiftUI

@Observable
class ChatViewModel {
    var chats: [Chat] = []

    private let api = APIClient.shared

    init() {}

    // MARK: - API

    func loadChats() async {
        do {
            let response = try await api.fetchChats()
            chats = response.map { r in
                Chat(
                    id: r.id,
                    contactName: r.contactName,
                    contactPhone: r.contactPhone,
                    isMuted: r.isMuted,
                    isPinned: r.isPinned,
                    createdAt: r.createdAt ?? Date()
                )
            }
        } catch {
            print("[ChatVM] loadChats error: \(error.localizedDescription)")
        }
    }

    func createChat(contactName: String, contactPhone: String) async -> Chat? {
        do {
            let r = try await api.createChat(contactName: contactName, contactPhone: contactPhone)
            let chat = Chat(
                id: r.id,
                contactName: r.contactName,
                contactPhone: r.contactPhone,
                isMuted: r.isMuted,
                isPinned: r.isPinned,
                createdAt: r.createdAt ?? Date()
            )
            chats.insert(chat, at: 0)
            return chat
        } catch {
            print("[ChatVM] createChat error: \(error.localizedDescription)")
            return nil
        }
    }

    func loadMessages(for chatID: UUID) async {
        do {
            let response = try await api.fetchMessages(chatID: chatID)
            guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
            chats[index].messages = response.map { r in
                Message(
                    id: r.id,
                    text: r.text,
                    isFromMe: r.isFromMe,
                    date: r.createdAt ?? Date()
                )
            }
        } catch {
            print("[ChatVM] loadMessages error: \(error.localizedDescription)")
        }
    }

    func sendMessage(to chatID: UUID, text: String) async {
        do {
            let r = try await api.sendMessage(chatID: chatID, text: text)
            guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
            let message = Message(id: r.id, text: r.text, isFromMe: r.isFromMe, date: r.createdAt ?? Date())
            chats[index].messages.append(message)
        } catch {
            print("[ChatVM] sendMessage error: \(error.localizedDescription)")
        }
    }

    func deleteChat(id: UUID) {
        Task {
            do {
                try await api.deleteChat(id: id)
                chats.removeAll { $0.id == id }
            } catch {
                print("[ChatVM] deleteChat error: \(error.localizedDescription)")
            }
        }
    }

    func deleteChat(at offsets: IndexSet) {
        for index in offsets {
            deleteChat(id: chats[index].id)
        }
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
