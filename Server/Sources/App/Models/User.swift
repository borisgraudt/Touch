import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "phone_number")
    var phoneNumber: String

    @Field(key: "display_name")
    var displayName: String

    @OptionalField(key: "avatar_url")
    var avatarUrl: String?

    @OptionalField(key: "verification_code")
    var verificationCode: String?

    @OptionalField(key: "code_expires_at")
    var codeExpiresAt: Date?

    @Field(key: "is_verified")
    var isVerified: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(phoneNumber: String, displayName: String? = nil) {
        self.phoneNumber = phoneNumber
        self.displayName = displayName ?? phoneNumber
        self.isVerified = false
    }
}
