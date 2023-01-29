# TinyFaces 👦🏼👨🏾👩🏻

<img src="/Public/images/github-header.png?raw=true" width="888">

Tiny Faces is a free crowd-sourced avatar gallery to use in your personal or commercial projects

Also check out our [Figma Plugin](https://github.com/maximedegreve/TinyFaces-Figma-Plugin) and [Sketch Plugin](https://github.com/maximedegreve/TinyFaces-Sketch-Plugin)

## 🦾 API

**Endpoints**
- `GET`: https://tinyfac.es/api/data?limit=50&gender=female&quality=0
- `GET`: https://tinyfac.es/api/avatar.jpg?gender=female&quality=0

**Query**
- `quality` : Filters the result(s) to lower or higher quality images by using a value from 0 to 10.
- `gender` : Possible values for gender can be found in [Gender.swift](/Sources/App/Models/Gender.swift)
- `limit` : To limit how many results you get back by using a value of 50 or lower. Only works with the data endpoint. When mixed with gender this could return less than n results.

**Limitations**

- Max requests per hour per IP address: `60` 
- When you've reached your limit you'll receive an error response with status code `493`

## 🎒 Before building (dependencies)

- Install [Xcode](https://developer.apple.com/xcode/)
- Install [Vapor Toolbox](https://docs.vapor.codes/4.0/install/macos/)
- Install [Docker Desktop](https://www.docker.com)
- Run `docker-compose up db`
- Run `Package.swift` using Xcode
- Change your Xcode working directory to your root folder: `Schemes > TinyFaces > Edit Scheme > Run > Options > Working Directory > [x]`
- Add a `.env` file to the local root directory this should have the values below:

```
THUMBOR_URL=URL
THUMBOR_KEY=ABCDEFG
```

Sadly we can't share our Thumbor setup and therefore you need to run a instance yourself for this to work.

## 🚧 Building

- Run the `Run` target in Xcode
- The first time this can take a long time because it will seed the database with random first names and last names.
- The application should now be running on [http://localhost:8080](http://localhost:8080)

If you want to test payments you need install and login to [Stripe CLI](https://stripe.com/docs/stripe-cli).

`stripe listen --forward-to localhost:8080/stripe/webhook`

## 💟 Heroku:

1.  In the project directory: `heroku create --buildpack vapor/vapor`
2.  Deploy using `git push heroku master` or setup continues deployment in Heroku.
3.  For logs use command `heroku logs`
4.  Make sure you fill in all Config Vars on Heroku, see the snippet below:

```
URL = https://tinyfac.es
MYSQL_URL =
PORT =
THUMBOR_URL=URL
THUMBOR_KEY=ABCDEFG
SWIFT_BUILD_CONFIGURATION = release
```

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.
