import Vapor
import Fluent
import FluentMySQLDriver

struct PrepareOldDatabase: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {

        guard let mysql = database as? MySQLDatabase else { return database.eventLoop.makeSucceededFuture(()) }

        return mysql.simpleQuery("RENAME TABLE `avatars` TO `old_avatars`;").flatMap { rows in

            return mysql.simpleQuery("RENAME TABLE `users` TO `old_users`;").flatMap { rows in

                return mysql.simpleQuery("DROP TABLE `fluent`;").flatMap { rows in

                    return mysql.simpleQuery("DROP TABLE `random_last_names`;").flatMap { _ in

                        return mysql.simpleQuery("DROP TABLE `random_first_names`;").transform(to: ())
                    }
                }

            }

        }

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededVoidFuture()
    }
}
