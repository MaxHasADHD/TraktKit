//
//  MLKeychain.swift
//  TVShows
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

public class MLKeychain {
    
    class func setString(value: String, forKey key: String) -> Bool {
        let data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrAccountValue: key,
            kSecValueDataValue: data
        ]
        
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        return status == noErr
    }
    
    class func loadData(forKey key: String) -> NSData? {
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrAccountValue: key,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitValue: kSecMatchLimitOneValue
        ]
        
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(keychainQuery as CFDictionaryRef, UnsafeMutablePointer($0)) }
        
        if status == -34018 {
            return dataTypeRef as? NSData
        }
        
        if status == noErr {
            return dataTypeRef as? NSData
        }
        else {
            return nil
        }
    }
    
    class func deleteItem(forKey key: String) -> Bool {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    public class func clear() -> Bool {
        let query = [ kSecClass as String : kSecClassGenericPassword ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
}