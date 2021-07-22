import Authentication
import Vapor

public func routes(_ router: Router) throws {
    // MARK: Controllers

    let slackSignUpController = SlackSignUpController()
    let slackCommand = SlackCommandController()
    let slackEventsController = SlackEventsController()
    let slackSettingsController = SlackSettingsController()
    let slackGreenlistController = SlackGreenlistController()
    let slackChannelsController = SlackChannelsController()
    let subscriptionController = SubscriptionController()
    let stripeHookController = StripeHookController()
    let userController = UserController()
    let closeController = CloseController()
    let sendController = SendController()
    let tokenController = TokenController()
    let timezoneController = TimezoneController()

    // MARK: Middleware

    let token = User.tokenAuthMiddleware()

    // MARK: Basic

    router.get { req -> String in
        "This is the API for Greenlist. (\(req.environment.name))"
    }
    router.grouped(token).get("user", use: userController.index)
    router.grouped(token).post("user", use: userController.settings)

    // MARK: Static Lists

    router.get("available-timezones", use: timezoneController.index)

    // MARK: Sign Up

    router.get("signup", "slack", use: slackSignUpController.index)
    router.get("slack", "redirect", use: slackSignUpController.redirect)

    // MARK: Slack

    router.post("slack", "interactive", use: slackCommand.interactive)
    router.post("slack", "events", use: slackEventsController.index)
    router.post("slack", "settings", use: slackSettingsController.index)
    router.post("slack", "manage", use: slackSettingsController.index) // Temporary
    router.post("slack", "greenlist", use: slackGreenlistController.index)
    router.grouped(token).get("slack", "channels", use: slackChannelsController.index)

    // MARK: Dev

    router.get("dev", "send", use: sendController.index)
    router.get("dev", "close", use: closeController.index)
    router.get("dev", "tokens", use: tokenController.index)

    // MARK: Stripe

    router.post("stripe", "hook", use: stripeHookController.index)
    router.get("stripe", "available-plans", use: subscriptionController.plans)
    router.grouped(token).post("stripe", "create-session", use: subscriptionController.index)
    router.grouped(token).delete("stripe", "cancel-subscriptions", use: subscriptionController.delete)
}
