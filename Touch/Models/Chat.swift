import Foundation

struct Chat: Identifiable {
    let id: UUID
    let contactName: String
    var messages: [Message]
    var isMuted: Bool
    var isPinned: Bool
    var lastMessageText: String {
        messages.last?.text ?? ""
    }
    var lastMessageDate: Date {
        messages.last?.date ?? createdAt
    }
    let createdAt: Date

    init(id: UUID = UUID(), contactName: String, messages: [Message] = [], isMuted: Bool = false, isPinned: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.contactName = contactName
        self.messages = messages
        self.isMuted = isMuted
        self.isPinned = isPinned
        self.createdAt = createdAt
    }
}
