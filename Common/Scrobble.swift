//
//  Scrobble.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Use this method when the video intially starts playing or is unpaused. This will remove any playback progress if it exists.
     
     **Note**: A watching status will auto expire after the remaining runtime has elpased. There is no need to re-send every 15 minutes.
     
     🔒 OAuth: Required
    */
    func scobbleStart() {
        assert(false, "Not implemented yet")
    }
    
    /**
     Use this method when the video is paused. The playback progress will be saved and **GET** `/sync/playback` can be used to resume the video from this exact position. Unpause a video by calling the **GET** `/scrobble/start` method again.
     
     🔒 OAuth: Required
     */
    func scobblePause() {
        assert(false, "Not implemented yet")
    }
    
    /**
     Use this method when the video is stopped or finishes playing on its own. If the progress is above 80%, the video will be scrobbled and the action will be set to **scrobble**.
     
     If the progress is less than 80%, it will be treated as a pause and the `action` will be set to `pause`. The playback progress will be saved and **GET** `/sync/playback` can be used to resume the video from this exact position.
     
     **Note**: If you prefer to use a threshold higher than 80%, you should use **GET** `/scrobble/pause` yourself so it doesn't create duplicate scrobbles.
     
     🔒 OAuth: Required
     */
    func scobbleStop() {
        assert(false, "Not implemented yet")
    }
}
