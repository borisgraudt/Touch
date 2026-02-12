import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("phone_number", .string, .required)
            .field("display_name", .string, .required)
            .field("avatar_url", .string)
            .field("verification_code", .string)
            .field("code_expires_at", .datetime)
            .field("is_verified", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .unique(on: "phone_number")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
