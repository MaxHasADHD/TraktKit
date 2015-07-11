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
    
    public class func setString(value: String, forKey key: String) -> Bool {
        let data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrAccountValue: key,
            kSecValueDataValue: data
        ]
        
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        if value == "" {
            
        }
        
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        return status == noErr
    }
    
    public class func loadData(forKey key: String) -> NSData? {
        let keychainQuery = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrAccountValue: key,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitValue: kSecMatchLimitOneValue
        ]
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionaryRef, &dataTypeRef)
        
        if status == noErr {
            return (dataTypeRef!.takeRetainedValue() as! NSData)
        } else {
            return nil
        }
    }
    
    public class func deleteItem(forKey key: String) -> Bool {
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