import JWT
import Vapor

struct AuthPayload: JWTPayload, Authenticatable {
    var sub: SubjectClaim
    var exp: ExpirationClaim

    var userID: UUID {
        UUID(uuidString: sub.value)!
    }

    init(userID: UUID) {
        self.sub = SubjectClaim(value: userID.uuidString)
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(7 * 24 * 3600)) // 7 days
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
