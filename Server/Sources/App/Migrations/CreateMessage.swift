import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("messages")
            .id()
            .field("chat_id", .uuid, .required, .references("chats", "id", onDelete: .cascade))
            .field("sender_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("text", .string, .required)
            .field("is_read", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("messages").delete()
    }
}
