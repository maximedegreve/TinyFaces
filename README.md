# TinyFaces 👦🏼👨🏾👩🏻

Free stock avatars for everyone

<img src="/Public/images/github-header.png?raw=true" width="888">

Tiny Faces is a free crowd-sourced avatar gallery to use in your personal or commercial projects

Also check out our [TinyFaces Sketch Plugin](https://github.com/maximedegreve/TinyFaces-Sketch-Plugin)

## 🎒 Before building (dependencies)

- Install [Xcode](https://developer.apple.com/xcode/)
- Install [Vapor Toolbox](https://docs.vapor.codes/4.0/install/macos/)
- Install [Docker Desktop](https://www.docker.com)
- Run `docker-compose up`
- Run `Package.swift` using Xcode

## 🚧 Building

- Run the `Run` target in Xcode
- The application should now be running on [http://localhost:8080](http://localhost:8080)

## 💟 Heroku:

1.  In the project directory: `heroku create --buildpack vapor/vapor`
2.  Add the JawsDB addon on Heroku using `heroku addons:create jawsdb:kitefin -a HEROKUAPPNAME --version=8.0 --encoding=utf8mb4`
3.  Deploy using `git push heroku master` or setup continues deployment in Heroku.
4.  For logs use command `heroku logs`
5.  Make sure you fill in all Config Vars on Heroku, see the snippet below:

```
URL = https://tinyfac.es
JAWSDB_URL =
PORT =
SWIFT_BUILD_CONFIGURATION = release
```

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.
