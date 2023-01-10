import Fluent
import FluentMySQLDriver
import Vapor
import Leaf
import Gatekeeper

public func configure(_ app: Application) throws {

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    let error = ErrorMiddleware.default(environment: app.environment)
    let files = FileMiddleware(publicDirectory: app.directory.publicDirectory)

    app.caches.use(.memory)
    app.passwords.use(.bcrypt)
    app.views.use(.leaf)

    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(error)
    app.middleware.use(files)
    
    app.gatekeeper.config = .init(maxRequests: 60, per: .hour)

    // app.logger.logLevel = .debug

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
    tlsConfiguration.certificateVerification = .none

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

    app.migrations.add(CreateSource())
    app.migrations.add(CreateAvatar())
    app.migrations.add(CreateFirstName(app: app))
    app.migrations.add(CreateLastName(app: app))
    app.migrations.add(MoveCloudinary())
    app.migrations.add(CreateAnalytic())
    try app.autoMigrate().wait()

    try routes(app)
}
