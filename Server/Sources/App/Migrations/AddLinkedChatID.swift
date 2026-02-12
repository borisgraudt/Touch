import Fluent

struct AddLinkedChatID: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chats")
            .field("linked_chat_id", .uuid)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chats")
            .deleteField("linked_chat_id")
            .update()
    }
}
