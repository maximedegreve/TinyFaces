//
//  AuthenticationController.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 13/12/2016.
//
//

import Vapor
import Turnstile
import TurnstileWeb
import TurnstileCrypto
import Auth
import HTTP
import Sessions
import Foundation

final class AuthenticationController {
    
    let facebook = Facebook(clientID: drop.config["facebook", "app_id"]?.string ?? "", clientSecret: drop.config["facebook", "app_secret"]?.string ?? "")
    let loginFacebookURL = "login-with-facebook"
    
    func addRoutes(drop: Droplet) {
        drop.get(loginFacebookURL, handler: loginWithFacebook)
        drop.get(loginFacebookURL,"consumer", handler: getAccessToken)
    }
    
    func getAccessToken(request: Request) throws -> ResponseRepresentable {
        
        let accessTokenInSession = getFBTokenAndSaveInSession(request: request)
        
        if accessTokenInSession{
            if let state = request.data["state"]?.string {
                
                if let decoded = state.fromBase64() {
                    
                    if let characterIndex = decoded.range(of: "redirect=")?.upperBound {
                        let redirect = decoded.substring(from: characterIndex)
                        return Response(redirect: redirect)
                    }

               }

            }
            
            return Response(redirect: "/new-face")
            
        } else {
            return Response(redirect: "../")
        }

    }
    
    func getFBTokenAndSaveInSession(request: Request) -> Bool {

        guard let state = request.cookies["OAuthState"] else {
            return false
        }
        
        var token: OAuth2Token?
        
        do {
            token = try self.facebook.exchange(authorizationCodeCallbackURL: request.uri.description, state: state)
            if let oAuth2Token = token{
                try request.session().data["accessToken"] = Node.string(oAuth2Token.accessToken.string)
            }
        } catch let error {
            Swift.print(error)
            return false
        }

        return true
        
    }
    
    func loginWithFacebook(request: Request) throws -> ResponseRepresentable {
        
        let state = "secure=\(URandom().secureToken)&\(request.uri.query ?? "")"
        let state64 = state.toBase64()
        
        var portString = ""
        if let port = request.uri.port {
            portString = ":" + String(port)
        }
 
        let consumerURL = "\(request.uri.scheme)://\(request.uri.host)\(portString)/\(loginFacebookURL)/consumer/"
        let response = Response(redirect: facebook.getLoginLink(redirectURL: consumerURL, state: state64, scopes: ["email"]).absoluteString)
        response.cookies["OAuthState"] = state64
        return response
    }

}
