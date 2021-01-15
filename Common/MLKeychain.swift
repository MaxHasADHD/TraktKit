//
//  MLKeychain.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/3/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

let serviceIdentifier = "com.litteral.TVShows"

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
    
    class func setString(value: String, forKey key: String) -> Bool {
        let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        let keychainQuery: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrAccountValue: key,
            kSecValueDataValue: data,
            kSecAttrAccessibleValue: kSecAttrAccessibleAfterFirstUnlockValue
        ]
        
        var result: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if result == errSecDuplicateItem {
            result = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueData: data] as CFDictionary)
        }
        return result == errSecSuccess
    }
    
    class func loadData(forKey key: String) -> Data? {
        let keychainQuery: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
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
            kSecAttrAccountValue: key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == noErr
    }
    
    /// Sets kSecAttrAccessible to kSecAttrAccessibleAfterFirstUnlock from the default value
    private class func updateAccessibleValue(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
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
        let query = [kSecClassValue : kSecClassGenericPasswordValue]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
