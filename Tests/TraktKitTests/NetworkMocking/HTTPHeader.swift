//
//  HTTPHeader.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 2/16/25.
//
import Foundation

public enum HTTPHeader {
    case contentType
    case apiVersion
    case apiKey(String)
    case page(Int)
    case pageCount(Int)
    case retry(TimeInterval)
    /// Sent with a 420 to say which limit was hit.
    case accountLimit(Int)
    /// Sent with a 420 to say whether the account is VIP.
    case vipUser(Bool)
    /// Sent with a 423 when the account is locked (as opposed to deactivated).
    case accountLocked(Bool)
    /// Sent with a 423 when the account has been deactivated.
    case accountDeactivated(Bool)

    public var key: String {
        switch self {
        case .contentType:
            "Content-type"
        case .apiVersion:
            "trakt-api-version"
        case .apiKey:
            "trakt-api-key"
        case .page:
            "X-Pagination-Page"
        case .pageCount:
            "X-Pagination-Page-Count"
        case .retry:
            "retry-after"
        case .accountLimit:
            "X-Account-Limit"
        case .vipUser:
            "X-VIP-User"
        case .accountLocked:
            "X-Account-Locked"
        case .accountDeactivated:
            "X-Account-Deactivated"
        }
    }

    public var value: String {
        switch self {
        case .contentType:
            "application/json"
        case .apiVersion:
            "2"
        case .apiKey(let apiKey):
            apiKey
        case .page(let page):
            page.description
        case .pageCount(let pageCount):
            pageCount.description
        case .retry(let delay):
            delay.description
        case .accountLimit(let limit):
            limit.description
        case .vipUser(let isVIP):
            isVIP.description
        case .accountLocked(let locked):
            locked.description
        case .accountDeactivated(let deactivated):
            deactivated.description
        }
    }
}
