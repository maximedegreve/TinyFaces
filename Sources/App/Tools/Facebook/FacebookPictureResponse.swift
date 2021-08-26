    import Vapor

    struct FacebookPictureResponseData: Content {
        var url: String
    }
    
    struct FacebookPictureResponse: Content {
        var data: FacebookPictureResponseData
    }
    
