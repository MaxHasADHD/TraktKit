//
//  DeviceCode.swift
//  TraktKit
//
//  Copyright © 2020 Maximilian Litteral. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

public struct DeviceCode: Codable {
    public let deviceCode: String
    public let userCode: String
    public let verificationURL: String
    public let expiresIn: TimeInterval
    public let interval: TimeInterval

#if canImport(UIKit) && canImport(CoreImage)
    public func getQRCode(scale: CGFloat = 3) -> UIImage? {
        guard
            let data = "\(verificationURL)/\(userCode)".data(using: .ascii),
            let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }

        filter.setValue(data, forKey: "inputMessage")

        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: scale, y: scale)) else {
            return nil
        }

        return UIImage(ciImage: output)
    }
#endif

    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case userCode = "user_code"
        case verificationURL = "verification_url"
        case expiresIn = "expires_in"
        case interval
    }
}
