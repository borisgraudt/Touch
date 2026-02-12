import Fluent
import Vapor

final class Chat: Model, Content, @unchecked Sendable {
    static let schema = "chats"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "contact_name")
    var contactName: String

    @Field(key: "contact_phone")
    var contactPhone: String

    @Field(key: "is_muted")
    var isMuted: Bool

    @Field(key: "is_pinned")
    var isPinned: Bool

    @OptionalField(key: "linked_chat_id")
    var linkedChatID: UUID?

    @Children(for: \.$chat)
    var messages: [Message]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(userID: UUID, contactName: String, contactPhone: String) {
        self.$user.id = userID
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.isMuted = false
        self.isPinned = false
    }
}
