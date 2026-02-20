//
//  ScrobbleResource.swift
//  TraktKit
//

import Foundation

extension TraktManager {
    /**
     Scrobbling is an automatic way to track what a user is watching in a media center. The media center should send events that correspond to starting, pausing, and stopping (or finishing) watching a movie or episode.
     */
    public struct ScrobbleResource {
        private let traktManager: TraktManager

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Actions

        /**
         Use this method when the video initially starts playing or is unpaused. This will remove any playback progress if it exists.

         > note: A watching status will auto expire after the remaining runtime has elapsed. There is no need to call this method again while continuing to watch the same item.

         🔒 OAuth Required

         - parameter scrobble: The scrobble body containing the movie or episode and progress percentage.
         */
        public func start(_ scrobble: TraktScrobble) -> Route<ScrobbleResult> {
            Route(paths: ["scrobble/start"], body: scrobble, method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Use this method when the video is paused. The playback progress will be saved and `GET /sync/playback` can be used to resume the video from this exact position. Unpause a video by calling `start` again.

         🔒 OAuth Required

         - parameter scrobble: The scrobble body containing the movie or episode and progress percentage.
         */
        public func pause(_ scrobble: TraktScrobble) -> Route<ScrobbleResult> {
            Route(paths: ["scrobble/pause"], body: scrobble, method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }

        /**
         Use this method when the video is stopped or finishes playing on its own. If the progress is above 80%, the video will be scrobbled and the `action` will be set to `scrobble`. A unique history `id` (64-bit integer) will be returned and can be used to reference this scrobble directly.

         If the progress is between 1% and 79%, it will be treated as a pause and the `action` will be set to `pause`. The playback progress will be saved and `GET /sync/playback` can be used to resume the video from this exact position.

         > note: If the same item was just scrobbled, a `409` HTTP status code will be returned to avoid scrobbling a duplicate.

         🔒 OAuth Required

         - parameter scrobble: The scrobble body containing the movie or episode and progress percentage.
         */
        public func stop(_ scrobble: TraktScrobble) -> Route<ScrobbleResult> {
            Route(paths: ["scrobble/stop"], body: scrobble, method: .POST, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
