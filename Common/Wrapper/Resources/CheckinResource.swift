//
//  CheckinResource.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 3/8/25.
//

extension TraktManager {
    /**
     Checking in is a manual action used by mobile apps allowing the user to indicate what they are watching right now. While not as effortless as scrobbling, checkins help fill in the gaps. You might be watching live tv, at a friend's house, or watching a movie in theaters. You can simply checkin from your phone or tablet in those situations. The item will display as watching on the site, then automatically switch to watched status once the duration has elapsed.
     */
    public struct CheckinResource {
        private let traktManager: TraktManager
        private let path: String = "checkin"

        internal init(traktManager: TraktManager) {
            self.traktManager = traktManager
        }

        // MARK: - Routes

        /**
         Check into a movie or episode. This should be tied to a user action to manually indicate they are watching something. The item will display as watching on the site, then automatically switch to watched status once the duration has elapsed. A unique history `id` (64-bit integer) will be returned and can be used to reference this checkin directly.

         ---
         **Sharing**

         The sharing object is optional and will apply the user's settings if not sent. If sharing is sent, each key will override the user's setting for that social network. Send true to post or false to not post on the indicated social network. You can see which social networks a user has connected with the ``TraktManager/CurrentUserResource/settings()`` method.

         > note: If a checkin is already in progress, a  ``TraktManager/TraktError/resourceAlreadyCreated`` error will thrown. Use ``TraktManager/UsersResource/watching()`` to get the timestamp of when the check-in is completed.

         🔒 OAuth Required
         */
        public func checkInto(
            movie: SyncId? = nil,
            episode: SyncId? = nil,
            sharing: ShareSettings? = nil,
            message: String? = nil
        ) async throws -> Route<TraktCheckinResponse> {
            Route(
                path: path,
                body: TraktCheckinBody(
                    movie: movie,
                    episode: episode,
                    sharing: sharing,
                    message: message
                ),
                method: .POST,
                requiresAuthentication: true,
                traktManager: traktManager
            )
        }

        /**
         Removes any active checkins, no need to provide a specific item.

         🔒 OAuth Required
         */
        public func deleteActiveCheckin() async throws -> EmptyRoute {
            EmptyRoute(path: path, method: .DELETE, requiresAuthentication: true, traktManager: traktManager)
        }
    }
}
