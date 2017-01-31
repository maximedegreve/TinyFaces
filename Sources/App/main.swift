import Vapor
import VaporMySQL
import Sessions
import Foundation
import HTTP
import CorsMiddleware

let drop = Droplet()

// Leave uncommented for release
drop.log.enabled = LogLevel.all

let memory = MemorySessions()

try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations.append(User.self)
drop.preparations.append(Avatar.self)
drop.preparations.append(FirstName.self)
drop.preparations.append(LastName.self)

// Middelware
let cors = CorsMiddleware()
drop.middleware.append(cors)

// Seed Data
let seed = SeedController()
seed.addRoutes(drop: drop)

// Sessions

let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)

// Web Side

let index = IndexController()
index.addRoutes(drop: drop)

let authentication = AuthenticationController()
authentication.addRoutes(drop: drop)

let newFace = NewFaceController()
newFace.addRoutes(drop: drop)

let admin = AdminController()
admin.addRoutes(drop: drop)

// API Side

drop.resource("api/users", UserController())

drop.run()


