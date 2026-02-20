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
        }
    }
}
