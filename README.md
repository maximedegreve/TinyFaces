# TinyFaces 👦🏼👨🏾👩🏻

Free stock avatars for everyone

<img src="/Public/images/github-header.png?raw=true" width="888">

Tiny Faces is a free crowd-sourced avatar gallery to use in your personal or commercial projects

Also check out our [TinyFaces Sketch Plugin](https://github.com/maximedegreve/TinyFaces-Sketch-Plugin)

## 🎒 Before building (dependencies)

- Install [Xcode](https://developer.apple.com/xcode/)
- Install [Vapor Toolbox](https://docs.vapor.codes/4.0/install/macos/)
- Install [Docker Desktop](https://www.docker.com)
- Run `docker-compose up db`
- Run `Package.swift` using Xcode
- Change your Xcode working directory to your root folder: `Schemes > TinyFaces > Edit Scheme > Run > Options > Working Directory > [x]`

## 🚧 Building

- Run the `Run` target in Xcode
- The first time this can take a long time because it will seed the database with random first names and last names.
- The application should now be running on [http://localhost:8080](http://localhost:8080)
- To test Facebook Login you need run the app on https, use for ngrok this. `ngrok http 8080 -subdomain tinyfaces`

## 💟 Heroku:

1.  In the project directory: `heroku create --buildpack vapor/vapor`
2.  Deploy using `git push heroku master` or setup continues deployment in Heroku.
3.  For logs use command `heroku logs`
4.  Make sure you fill in all Config Vars on Heroku, see the snippet below:

```
URL = https://tinyfac.es
MYSQL_URL =
PORT =
SWIFT_BUILD_CONFIGURATION = release
```

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.
