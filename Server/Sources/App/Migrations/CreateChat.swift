import Fluent

struct CreateChat: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chats")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("contact_name", .string, .required)
            .field("contact_phone", .string, .required)
            .field("is_muted", .bool, .required, .sql(.default(false)))
            .field("is_pinned", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chats").delete()
    }
}
