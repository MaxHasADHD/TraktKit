//
//  MLKeychain.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/3/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

/// Every item TraktKit stores is filed under this service.
///
/// This must never be omitted from a query. The keychain treats an absent
/// attribute as a wildcard when searching, so a generic-password lookup by
/// account alone ("accessToken") also matches items belonging to *other*
/// applications that happen to use the same account name. On macOS that means a
/// keychain access prompt naming someone else's credential, and a `SecItemDelete`
/// — which removes every match rather than one — aimed at it.
let serviceIdentifier = "com.litteral.TraktKit"

/// The service value carried by items written before scoping was introduced.
/// Those were added with no service attribute at all, which the keychain stores
/// as an empty string. Querying for it explicitly matches only TraktKit's own
/// legacy items and can never reach another application's.
private let legacyServiceIdentifier = ""

let kSecClassValue = kSecClass as String
let kSecAttrAccountValue = kSecAttrAccount as String
let kSecValueDataValue = kSecValueData as String
let kSecClassGenericPasswordValue = kSecClassGenericPassword as String
let kSecAttrServiceValue = kSecAttrService as String
let kSecMatchLimitValue = kSecMatchLimit as String
let kSecReturnDataValue = kSecReturnData as String
let kSecMatchLimitOneValue = kSecMatchLimitOne as String
let kSecAttrAccessibleValue = kSecAttrAccessible as String
let kSecAttrAccessibleAfterFirstUnlockValue = kSecAttrAccessibleAfterFirstUnlock as String

public class MLKeychain {

    @discardableResult
    class func setString(value: String, forKey key: String) -> Bool {
        let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        let keychainQuery: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: serviceIdentifier,
            kSecAttrAccountValue: key,
            kSecValueDataValue: data,
            kSecAttrAccessibleValue: kSecAttrAccessibleAfterFirstUnlockValue
        ]
        
        var result: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if result == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClassValue: kSecClassGenericPasswordValue,
                kSecAttrServiceValue: serviceIdentifier,
                kSecAttrAccountValue: key
            ]
            result = SecItemUpdate(updateQuery as CFDictionary, [kSecValueData: data] as CFDictionary)
        }
        return result == errSecSuccess
    }
    
    class func loadData(forKey key: String) -> Data? {
        let keychainQuery: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: serviceIdentifier,
            kSecAttrAccountValue: key,
            kSecReturnDataValue: kCFBooleanTrue!,
            kSecMatchLimitValue: kSecMatchLimitOneValue,
            kSecAttrAccessibleValue: kSecAttrAccessibleAfterFirstUnlockValue
        ]
        
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0)) }
        
        if status == errSecItemNotFound {
            if updateAccessibleValue(for: key) {
                return loadData(forKey: key)
            }
        }
        
        if status == -34018 {
            return dataTypeRef as? Data
        }
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    @discardableResult
    class func deleteItem(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: serviceIdentifier,
            kSecAttrAccountValue: key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == noErr
    }
    
    /// Sets kSecAttrAccessible to kSecAttrAccessibleAfterFirstUnlock from the default value
    private class func updateAccessibleValue(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: serviceIdentifier,
            kSecAttrAccountValue: key
        ]
        
        let attributes: [String: Any] = [
            kSecAttrAccessibleValue: kSecAttrAccessibleAfterFirstUnlockValue
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { return false }
        return true
    }
    
    public class func clear() -> Bool {
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: serviceIdentifier
        ]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    // MARK: - Migration

    /// Moves an item written by a pre-scoping version of TraktKit onto the scoped
    /// service, so updating doesn't sign the user out.
    ///
    /// Both the read and the delete are pinned to the empty legacy service, which
    /// matches only items TraktKit itself wrote — neither can touch, or raise an
    /// access prompt for, a credential belonging to another application.
    ///
    /// When a legacy and a scoped item both exist the legacy one wins: the only
    /// way to reach that state is an older version writing a token *after* a newer
    /// one migrated, which makes the legacy copy the fresher of the two.
    class func migrateLegacyItem(forKey key: String) {
        let legacyQuery: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: legacyServiceIdentifier,
            kSecAttrAccountValue: key,
            kSecReturnDataValue: kCFBooleanTrue!,
            kSecMatchLimitValue: kSecMatchLimitOneValue
        ]

        var dataTypeRef: AnyObject?
        let status: OSStatus = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(legacyQuery as CFDictionary, UnsafeMutablePointer($0)) }

        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else { return }

        guard setString(value: value, forKey: key) else { return }

        let deleteQuery: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: legacyServiceIdentifier,
            kSecAttrAccountValue: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
    }
}
