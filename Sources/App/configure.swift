import Fluent
import FluentMySQLDriver
import Vapor
import Leaf
import Gatekeeper
import QueuesFluentDriver
import JWT

public func configure(_ app: Application) throws {

    // 🗑️ Reset middleware
    app.middleware = .init()

    // 🌐 Cors
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .referer, .accessControlAllowOrigin, .accessControlAllowCredentials],
        allowCredentials: true
    )

    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // 🏋️ Sessions
    app.sessions.configuration.cookieName = "tinyfaces"
    app.sessions.use(.memory)
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())

    // 📁 Files
    let fileMiddleware = FileMiddleware(
        publicDirectory: app.directory.publicDirectory
    )
    app.middleware.use(fileMiddleware)

    // 💂‍♂️ Cache
    app.caches.use(.memory)

    // 🚨 Custom errors
    app.middleware.use(ErrorMiddleware.custom(environment: app.environment))

    // 🔑 JWT
    app.jwt.signers.use(.hs256(key: Environment.signer))

    // 📧 Email (Templates)
    app.views.use(.leaf)

    // 👮 Rate limit
    app.gatekeeper.config = .init(maxRequests: 30, per: .minute)
    app.middleware.use(GatekeeperMiddleware())

    // 🤓 Debug
    // app.logger.logLevel = .debug

    // 👮‍♂️ TLS
    var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
    tlsConfiguration.certificateVerification = .none

    // 🍯 Database
    if
        let mysqlUrl = Environment.mysqlUrl,
        let url = URL(string: mysqlUrl) {

        let mysqlConfig = MySQLConfiguration(
            hostname: url.host!,
            port: url.port!,
            username: url.user!,
            password: url.password!,
            database: url.path.split(separator: "/").last.flatMap(String.init),
            tlsConfiguration: tlsConfiguration
        )
        app.databases.use(.mysql(configuration: mysqlConfig, maxConnectionsPerEventLoop: 4, connectionPoolTimeout: .seconds(10)), as: .mysql)

    } else {
        app.databases.use(.mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tlsConfiguration: tlsConfiguration,
            connectionPoolTimeout: .seconds(10)), as: .mysql)
    }

    // 🚡 Migrations
    app.migrations.add(CreateSource())
    app.migrations.add(CreateAvatar())
    app.migrations.add(CreateFirstName(app: app))
    app.migrations.add(CreateLastName(app: app))
    app.migrations.add(MoveCloudinary())
    app.migrations.add(CreateAnalytic())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateSubscription())
    app.migrations.add(CreateAvatarAI())
    app.migrations.add(JobMetadataMigrate())
    try app.autoMigrate().wait()

    // 💼 Register Jobs
    app.queues.use(.fluent())
    app.queues.configuration.workerCount = 4
    app.queues.add(EmailJob())

    // 💼 Start jobs
    try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()

    try routes(app)
}
