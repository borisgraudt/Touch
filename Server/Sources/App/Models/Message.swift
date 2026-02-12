import Fluent
import Vapor

final class Message: Model, Content, @unchecked Sendable {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "chat_id")
    var chat: Chat

    @Parent(key: "sender_id")
    var sender: User

    @Field(key: "text")
    var text: String

    @Field(key: "is_read")
    var isRead: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(chatID: UUID, senderID: UUID, text: String) {
        self.$chat.id = chatID
        self.$sender.id = senderID
        self.text = text
        self.isRead = false
    }
}
