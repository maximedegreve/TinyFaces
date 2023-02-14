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
        allowedOrigin: .any(["http://localhost:3000", "https://tinyfac.es", "https://api.tinyfac.es"]),
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .referer, .accessControlAllowOrigin, .accessControlAllowCredentials],
        allowCredentials: true
    )
    
    let cors = CORSMiddleware(configuration: corsConfiguration)
    let error = ErrorMiddleware.default(environment: app.environment)

    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(error)
    
    // 🔑 JWT
    app.jwt.signers.use(.hs256(key: Environment.signer))

    // 📧 Email (Templates)
    app.views.use(.leaf)
    
    // 👮 Rate limit
    app.caches.use(.fluent)
    app.gatekeeper.config = .init(maxRequests: 30, per: .minute)
    app.gatekeeper.keyMakers.use(.hostname)
    app.middleware.use(GatekeeperMiddleware())
    
    // 🤓 Debug
    // app.logger.logLevel = .debug
    
    // 🏋️ Sessions
    app.sessions.configuration.cookieName = "layers"
    app.sessions.use(.memory)
    
    // 📆 Date encoding
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    ContentConfiguration.global.use(decoder: decoder, for: .json)

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
