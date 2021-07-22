import Authentication
import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_: inout Config, _: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    let serverConfig = NIOServerConfig.default(workerCount: 1)
    services.register(serverConfig)

    let poolConfig = DatabaseConnectionPoolConfig(maxConnections: 8)
    services.register(poolConfig)

    // Register middleware
    var middlewares = MiddlewareConfig()

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )

    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self)
    services.register(middlewares)

    // Configure a MySQL database
    var databases = DatabasesConfig()
    // databases.enableLogging(on: .mysql)

    var databaseConfig: MySQLDatabaseConfig
    if let url = Environment.jawsDBUrl {
        databaseConfig = try MySQLDatabaseConfig(url: url)!
    } else {
        databaseConfig = MySQLDatabaseConfig(hostname: "127.0.0.1",
                                             port: 3306,
                                             username: Environment.developmentMySQLUsername,
                                             password: Environment.developmentMySQLPassword,
                                             database: Environment.developmentMySQLDatabase,
                                             transport: .unverifiedTLS)
    }

    // Register the configured MySQL database to the database config.
    let mysql = MySQLDatabase(config: databaseConfig)
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    // Global Config
    var contentConfig = ContentConfig.default()
    services.register(contentConfig)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Team.self, database: DatabaseIdentifier<Team.Database>.mysql)

    services.register(migrations)
}
