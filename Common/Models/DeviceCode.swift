//
//  DeviceCode.swift
//  TraktKit
//
//  Copyright © 2020 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct DeviceCode {
    public let device_code:String
    public let user_code:String
    public let verification_url:String
    public let expires_in:Int
    public let interval:Int
    
    func getQRCode() -> UIImage? {
        let data = self.verification_url.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
