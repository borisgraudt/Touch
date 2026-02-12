import Foundation

struct Chat: Identifiable {
    let id: UUID
    let contactName: String
    var messages: [Message]
    var lastMessageText: String {
        messages.last?.text ?? ""
    }
    var lastMessageDate: Date {
        messages.last?.date ?? createdAt
    }
    let createdAt: Date

    init(id: UUID = UUID(), contactName: String, messages: [Message] = [], createdAt: Date = Date()) {
        self.id = id
        self.contactName = contactName
        self.messages = messages
        self.createdAt = createdAt
    }
}
