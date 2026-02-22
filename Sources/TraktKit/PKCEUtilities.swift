//
//  PKCEUtilities.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/22/26.
//

import Foundation
import CryptoKit

/// Utilities for PKCE (Proof Key for Code Exchange) OAuth flow
public enum PKCEUtilities {
    
    /// Generates a cryptographically secure random code verifier
    /// - Returns: A base64url-encoded string of 32 random bytes (43 characters)
    public static func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }
    
    /// Generates a code challenge from a code verifier using SHA256
    /// - Parameter verifier: The code verifier string
    /// - Returns: A base64url-encoded SHA256 hash of the verifier
    public static func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64URLEncodedString()
    }
}

extension Data {
    /// Converts data to base64url encoding (RFC 4648)
    /// - Returns: Base64url-encoded string with padding removed
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
