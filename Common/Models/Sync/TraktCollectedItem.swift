//
//  TraktCollectedItem.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 10/21/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktCollectedItem: Codable, Hashable {
    
    public var lastCollectedAt: Date
    public let lastUpdatedAt: Date
    
    public var movie: TraktMovie?
    public var show: TraktShow?
    public var seasons: [TraktCollectedSeason]?
    public var metadata: Metadata?
    
    enum MovieCodingKeys: String, CodingKey {
        case lastCollectedAt = "collected_at"
        case lastUpdatedAt = "updated_at"
        case movie
        case metadata
    }
    
    enum ShowCodingKeys: String, CodingKey {
        case lastCollectedAt = "last_collected_at"
        case lastUpdatedAt = "last_updated_at"
        case show
        case seasons
        case metadata
    }

    public init(from decoder: Decoder) throws {
        if let movieContainer = try? decoder.container(keyedBy: MovieCodingKeys.self), !movieContainer.allKeys.isEmpty {
            movie = try movieContainer.decodeIfPresent(TraktMovie.self, forKey: .movie)
            lastUpdatedAt = try movieContainer.decode(Date.self, forKey: .lastUpdatedAt)
            lastCollectedAt = try movieContainer.decode(Date.self, forKey: .lastCollectedAt)
            metadata = try movieContainer.decodeIfPresent(Metadata.self, forKey: .metadata)
        } else {
            let showContainer = try decoder.container(keyedBy: ShowCodingKeys.self)
            show = try showContainer.decodeIfPresent(TraktShow.self, forKey: .show)
            seasons = try showContainer.decodeIfPresent([TraktCollectedSeason].self, forKey: .seasons)
            lastUpdatedAt = try showContainer.decode(Date.self, forKey: .lastUpdatedAt)
            lastCollectedAt = try showContainer.decode(Date.self, forKey: .lastCollectedAt)
            metadata = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let movie = movie {
            var container = encoder.container(keyedBy: MovieCodingKeys.self)
            try container.encodeIfPresent(movie, forKey: .movie)
            try container.encode(lastCollectedAt, forKey: .lastCollectedAt)
            try container.encode(lastUpdatedAt, forKey: .lastUpdatedAt)
        } else {
            var container = encoder.container(keyedBy: ShowCodingKeys.self)
            try container.encodeIfPresent(show, forKey: .show)
            try container.encodeIfPresent(seasons, forKey: .seasons)
            try container.encode(lastCollectedAt, forKey: .lastCollectedAt)
            try container.encode(lastUpdatedAt, forKey: .lastUpdatedAt)
        }
    }
    
    public struct Metadata: Codable, Hashable {
        public let mediaType: MediaType?
        public let resolution: Resolution?
        public let hdr: HDR?
        public let audio: Audio?
        public let audioChannels: AudioChannels?
        public let is3D: Bool
        
        enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
            case resolution
            case hdr
            case audio
            case audioChannels = "audio_channels"
            case is3D = "3d"
        }
        
        /// Custom decoder to fail silently if Trakt adds new metadata option.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            mediaType = try? container.decodeIfPresent(MediaType.self, forKey: .mediaType)
            resolution = try? container.decodeIfPresent(Resolution.self, forKey: .resolution)
            hdr = try? container.decodeIfPresent(HDR.self, forKey: .hdr)
            audio = try? container.decodeIfPresent(Audio.self, forKey: .audio)
            audioChannels = try? container.decodeIfPresent(AudioChannels.self, forKey: .audioChannels)
            is3D = try container.decodeIfPresent(Bool.self, forKey: .is3D) ?? false
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
    
    public enum HDR: String, Codable {
        case dolbyVision = "dolby_vision"
        case hdr10 = "hdr10"
        case hdr10Plus = "hdr10_plus"
        case hlg
    }
    
    public enum Audio: String, Codable {
        case dolbyDigital = "dolby_digital"
        case dolbyDigitalPlus = "dolby_digital_plus"
        case dolbyDigitalPlusAtmos = "dolby_digital_plus_atmos"
        case dolbyAtmos = "dolby_atmos"
        case dolbyTrueHD = "dolby_truehd"
        case dolbyTrueHDAtmos = "dolby_truehd_atmos"
        case dolbyProLogic = "dolby_prologic"
        case dts
        case dtsHDMA = "dts_ma"
        case dtsHDHR = "dts_hr"
        case dtsX = "dts_x"
        case auro3D = "auro_3d"
        case mp3
        case mp2
        case aac
        case lpcm
        case ogg
        case wma
        case flac
    }
    
    public enum AudioChannels: String, Codable {
        case tenOne = "10.1"
        case nineOne = "9.1"
        case sevenOneFour = "7.1.4"
        case sevenOneTwo = "7.1.2"
        case sevenOne = "7.1"
        case sixOne = "6.1"
        case fiveOneFour = "5.1.4"
        case fiveOneTwo = "5.1.2"
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
}

public struct TraktCollectedSeason: Codable, Hashable {
    
    /// Season number
    public var number: Int
    public var episodes: [TraktCollectedEpisode]
}

public struct TraktCollectedEpisode: Codable, Hashable {
    
    public var number: Int
    public var collectedAt: Date
    public var metadata: TraktCollectedItem.Metadata?
    
    enum CodingKeys: String, CodingKey {
        case number
        case collectedAt = "collected_at"
        case metadata
    }
}
