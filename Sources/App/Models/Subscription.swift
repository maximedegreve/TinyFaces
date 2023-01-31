import Fluent
import Vapor

final class Subscription: Model, Content {
    static let schema = "subscriptions"

    @ID(custom: .id)
    var id: Int?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "stripe_id")
    var stripeId: String

    @Field(key: "stripe_product_id")
    var stripeProductId: String
    
    @Field(key: "stripe_status")
    var stripeStatus: String

    @Field(key: "cancel_at_period_end")
    var cancelAtPeriodEnd: Bool
    
    @Field(key: "current_period_end")
    var currentPeriodEnd: Date
    
    @Field(key: "canceled_at")
    var canceledAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }
    
    init(userId: User.IDValue, stripeId: String, stripeProductId: String, stripeStatus: String, cancelAtPeriodEnd: Bool, currentPeriodEnd: Date) {
        self.$user.id = userId
        self.stripeId = stripeId
        self.stripeProductId = stripeProductId
        self.stripeStatus = stripeStatus
        self.cancelAtPeriodEnd = cancelAtPeriodEnd
        self.currentPeriodEnd = currentPeriodEnd
    }

}
