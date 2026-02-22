//
//  OAuthBody.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/5/25.
//

struct OAuthBody: TraktObject {
    let code: String?
    let accessToken: String?
    let refreshToken: String?

    let clientId: String?
    let clientSecret: String?

    let redirectURI: String?
    let grantType: String?
    
    // PKCE parameters
    let codeVerifier: String?
    let codeChallenge: String?
    let codeChallengeMethod: String?

    enum CodingKeys: String, CodingKey {
        case code
        case accessToken = "token"
        case refreshToken = "refresh_token"
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case redirectURI = "redirect_uri"
        case grantType = "grant_type"
        case codeVerifier = "code_verifier"
        case codeChallenge = "code_challenge"
        case codeChallengeMethod = "code_challenge_method"
    }

    init(
        code: String? = nil,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        clientId: String? = nil,
        clientSecret: String? = nil,
        redirectURI: String? = nil,
        grantType: String? = nil,
        codeVerifier: String? = nil,
        codeChallenge: String? = nil,
        codeChallengeMethod: String? = nil
    ) {
        self.code = code
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.grantType = grantType
        self.codeVerifier = codeVerifier
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
    }
}
