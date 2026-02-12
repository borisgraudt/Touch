import Vapor
import Fluent
import FluentPostgresDriver
import JWT

func configure(_ app: Application) throws {
    // MARK: - Server (listen on all interfaces so iPhone can connect)
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080

    // MARK: - Database
    app.databases.use(
        .postgres(configuration: .init(
            hostname: Environment.get("DB_HOST") ?? "localhost",
            port: Environment.get("DB_PORT").flatMap(Int.init) ?? 5432,
            username: Environment.get("DB_USER") ?? "boris",
            password: Environment.get("DB_PASSWORD") ?? "",
            database: Environment.get("DB_NAME") ?? "touch_db",
            tls: .disable
        )),
        as: .psql
    )

    // MARK: - Migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateChat())
    app.migrations.add(CreateMessage())
    app.migrations.add(AddLinkedChatID())

    try app.autoMigrate().wait()

    // MARK: - JWT
    let jwtSecret = Environment.get("JWT_SECRET") ?? "dev-secret-change-in-production"
    app.jwt.signers.use(.hs256(key: jwtSecret))

    // MARK: - Routes
    try routes(app)
}
