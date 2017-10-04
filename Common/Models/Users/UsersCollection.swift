//
//  UsersCollection.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct UsersCollection: Codable {
    public let collectedAt: Date
    public let movie: TraktMovie?
    public let show: TraktShow?
    public let metadata: Metadata
    
    public struct Metadata: Codable {
        public let mediaType: MediaType?
        public let resolution: Resolution?
        public let audio: Audio?
        public let audioChannels: AudioChannels?
        public let is3D: Bool
        
        enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
            case resolution
            case audio
            case audioChannels = "audio_channels"
            case is3D = "3d"
        }
    }
    
    public enum MediaType: String, Codable {
        case digital
        case bluray
        case hdDVD = "hddvd"
        case dvd
        case laserDisc = "laserdisc"
        case vhs
        case betamax
        case videoCD = "vcd"
    }
    
    public enum Resolution: String, Codable {
        case udh4k = "uhd_4k"
        case hd1080p = "hd_1080p"
        case hd1080i = "hd_1080i"
        case hd720p = "hd_720p"
        case sd480p = "sd_480p"
        case sd480i = "sd_480i"
        case sd576p = "sd_576p"
        case sd576i = "sd_576i"
    }
    
    public enum Audio: String, Codable {
        case dolbyDigital = "dolby_digital"
        case dolbyDigitalPlus = "dolby_digital_plus"
        case dolbyTrueHD = "dolby_truehd"
        case dolbyProLogic = "dolby_prologic"
        case dts
        case dtsHD = "dts_ma"
        case mp3
        case aac
        case lpcm
        case ogg
        case wma
    }
    
    public enum AudioChannels: String, Codable {
        case sevenOne = "7.1"
        case sixOne = "6.1"
        case fiveOne = "5.1"
        case five = "5.0"
        case fourOne = "4.1"
        case four = "4.0"
        case threeOne = "3.1"
        case three = "3.0"
        case twoOne = "2.1"
        case two = "2.0"
        case one = "1.0"
    }
    
    enum CodingKeys: String, CodingKey {
        case collectedAt = "collected_at"
        case movie
        case show
        case metadata
    }
}
