//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit

class C {
    static let DEBUG:Bool = true

    //static let BASE_URL:String = "https://api.frazzle.wtf"; //Production
    static let BASE_URL:String = "http://54.245.28.122"
    static let WEB_SERVICES_VERSION:String = "/1.0"
    static let URL_SERVER:String = BASE_URL + WEB_SERVICES_VERSION

    static let HEADERS = [
            "FrazzleTV-Client": "iOS",
            "X-FrazzleTV-REST-API-Key": "26c7475557784fefaed9649d05c189b0",
            "X-FrazzleTV-REST-API-Secret": "660221f2573542d38664a06843300990",
            "Content-Type": "application/json"
    ]

    enum UserType {
        case USERS
        case PEOPLE
        case SHOPS
        case MERCHANT
        case ADMIN
        case SUPER_USER
    }

    enum TimelineType {
        case SHOPS
        case HERBS
        case TUNES
        case VIBES
        case LIVE
        case SEARCH
    }

    enum UsersType {
        case PROFILES
        case FOLLOWERS
        case FOLLOWING
        case SEARCH
    }

    enum TabType: String {
        case HOME_HERBS
        case HOME_SHOPS
        case HOME_TUNES
        case HOME_VIBES
        case SHOPS
        case USERS_PROFILES
        case USERS_FOLLOWERS
        case USERS_FOLLOWING
        case LIVE
        case SEARCH
    }

    enum SearchType: String {
        case Posts
        case Users
        case People
        case Shops
    }

    enum MediaType: String {
        case STATIC_VIDEO
        case LIVE_VIDEO

    }

    enum PostType: String {
        case REGULAR
        case LIVE
    }

    enum CategoryType: String {
        case TUNES
        case VIBES
        case HERBS
        case SHOPS
    }

    enum BroadcastEventType: String {
        case PUBLISH
        case END
    }

    enum PlayerStatus {
        case NULL
        case INITIALIZED
        case BINDING
        case LOADING
        case READY
        case PLAYING
        case PAUSED
        case STOPPED
    }

    static let TOP_TAB_NAME_HOME_HERBS = "HERBS"
    static let TOP_TAB_NAME_HOME_SHOPS = "SHOPS"
    static let TOP_TAB_NAME_HOME_TUNES = "TUNES"
    static let TOP_TAB_NAME_HOME_VIBES = "VIBES"

    static let TOP_TAB_NAME_SHOPS_LIST = "LIST"
    static let TOP_TAB_NAME_SHOPS_MAP = "MAP"

    static let TOP_TAB_NAME_PEOPLE_PEOPLE = "PROFILES"
    static let TOP_TAB_NAME_PEOPLE_FOLLOWING = "FOLLOWING"
    static let TOP_TAB_NAME_PEOPLE_FOLLOWERS = "FOLLOWERS"

    static let TOP_TAB_NAME_LIVE_STREAMS_LIVE = "LIVE STREAMS"
    static let TOP_TAB_NAME_LIVE_STREAMS_UPCOMING = "UPCOMING EVENTS"


    static let TOP_TAB_NAME_SEARCH = "SEARCH"
    static let TOP_TAB_NAME_SEARCH_PEOPLE = "PEOPLE"
    static let TOP_TAB_NAME_SEARCH_SHOPS = "SHOPS"
    static let TOP_TAB_NAME_SEARCH_TOP = "TOP"

    static let BOTTOM_TAB_NAME_HOME = "Home"
    static let BOTTOM_TAB_NAME_SHOPS = "Shops"
    static let BOTTOM_TAB_NAME_PEOPLE = "People"
    static let BOTTOM_TAB_NAME_LIVE = "Live Streams"
    static let BOTTOM_TAB_NAME_SEARCH = "Search"

    static let COLOR_WHITE:String = "#FFFFFF"
    static let COLOR_WHITE_ALABASTER:String = "#FAFAFA"
    static let COLOR_GREY_ALUMINUM:String = "#9B9B9B"

    static let COLOR_HOME_HERBS:String = "#7ED321"
    static let COLOR_HOME_SHOPS:String = "#000000"
    static let COLOR_HOME_TUNES:String = "#F53F03"
    static let COLOR_HOME_VIBES:String = "#F8E71C"
    static let COLOR_SHOPS:String = "#000000"
    static let COLOR_PROFILES:String = "#000000"
    static let COLOR_LIVE:String = "#000000"
    static let COLOR_SEARCH:String = "#000000"
    static let COLOR_DEFAULT:String = "#000000"

    static let COLOR_ACCENT_HOME_HERBS:String = "#7ED321"
    static let COLOR_ACCENT_HOME_SHOPS:String = "#F45621"
    static let COLOR_ACCENT_HOME_TUNES:String = "#F53F03"
    static let COLOR_ACCENT_HOME_VIBES:String = "#F8E71C"
    static let COLOR_ACCENT_SHOPS:String = "#F45621"
    static let COLOR_ACCENT_PROFILES:String = "#F45621"
    static let COLOR_ACCENT_LIVE:String = "#F45621"
    static let COLOR_ACCENT_SEARCH:String = "#F45621"
    static let COLOR_ACCENT_DEFAULT:String = "#F45621"

    static let TOP_TAB_INDICATOR_HEIGHT:CGFloat = 3


    static let USER_LOGGED_IN:String = "USER_LOGGED_IN"
    static let USER_NOT_LOGGED_IN:String = "USER_NOT_LOGGED_IN"
    static let USER_LOGGED_OUT:String = "USER_LOGGED_OUT"

    static let BOTTOM_TAB_CHANGED:String = "BOTTOM_TAB_CHANGED"
    static let TOP_TAB_CHANGED:String = "TOP_TAB_CHANGED"

    static let POSTS_DOWNLOADED:String = "POSTS_DOWNLOADED"
    static let POSTS_NOT_DOWNLOADED:String = "POSTS_NOT_DOWNLOADED"

    static let USER_POSTS_DOWNLOADED:String = "USER_POSTS_DOWNLOADED"
    static let USER_POSTS_NOT_DOWNLOADED:String = "USER_POSTS_NOT_DOWNLOADED"

    static let SEARCH_POSTS_DOWNLOADED:String = "SEARCH_POSTS_DOWNLOADED"
    static let SEARCH_POSTS_NOT_DOWNLOADED:String = "SEARCH_POSTS_NOT_DOWNLOADED"

    static let SEARCH_USERS_DOWNLOADED:String = "SEARCH_USERS_DOWNLOADED"
    static let SEARCH_USERS_NOT_DOWNLOADED:String = "SEARCH_USERS_NOT_DOWNLOADED"

    static let SEARCH_SHOPS_DOWNLOADED:String = "SEARCH_SHOPS_DOWNLOADED"
    static let SEARCH_SHOPS_NOT_DOWNLOADED:String = "SEARCH_SHOPS_NOT_DOWNLOADED"

    static let SHOPS_DOWNLOADED:String = "SHOPS_DOWNLOADED"
    static let SHOPS_NOT_DOWNLOADED:String = "SHOPS_NOT_DOWNLOADED"

    static let USERS_DOWNLOADED:String = "USERS_DOWNLOADED"
    static let USERS_NOT_DOWNLOADED:String = "USERS_NOT_DOWNLOADED"

    static let FOLLOWERS_DOWNLOADED:String = "FOLLOWERS_DOWNLOADED"
    static let FOLLOWERS_NOT_DOWNLOADED:String = "FOLLOWERS_NOT_DOWNLOADED"

    static let FOLLOWING_DOWNLOADED:String = "FOLLOWING_DOWNLOADED"
    static let FOLLOWING_NOT_DOWNLOADED:String = "FOLLOWING_NOT_DOWNLOADED"

    static let FOLLOWING_ADDED:String = "FOLLOWING_ADDED"
    static let FOLLOWING_NOT_ADDED:String = "FOLLOWING_NOT_ADDED"

    static let FOLLOWING_DELETED:String = "FOLLOWING_DELETED"
    static let FOLLOWING_NOT_DELETED:String = "FOLLOWING_NOT_DELETED"

    static let MEDIA_INFO_DOWNLOADED:String = "MEDIA_INFO_DOWNLOADED"
    static let MEDIA_INFO_NOT_DOWNLOADED:String = "MEDIA_INFO_NOT_DOWNLOADED"

    static let POST_INFO_UPLOADED:String = "POST_INFO_UPLOADED"
    static let POST_INFO_NOT_UPLOADED:String = "POST_INFO_NOT_UPLOADED"

    static let BROADCAST_POST_INFO_UPLOADED:String = "BROADCAST_POST_INFO_UPLOADED"
    static let BROADCAST_POST_INFO_NOT_UPLOADED:String = "BROADCAST_POST_INFO_NOT_UPLOADED"

    static let BROADCAST_EVENT_SEND:String = "BROADCAST_EVENT_SEND"
    static let BROADCAST_EVENT_NOT_SEND:String = "BROADCAST_EVENT_NOT_SEND"

    static let NOTIFICATION_POST_DOWNLOADED_APP_DELEGATE:String = "NOTIFICATION_POST_DOWNLOADED_APP_DELEGATE"
    static let NOTIFICATION_POST_DOWNLOADED:String = "NOTIFICATION_POST_DOWNLOADED"
    static let NOTIFICATION_POST_NOT_DOWNLOADED:String = "NOTIFICATION_POST_NOT_DOWNLOADED"

    static let MEDIA_UPLOADED:String = "MEDIA_UPLOADED"
    static let MEDIA_NOT_UPLOADED:String = "MEDIA_NOT_UPLOADED"

    static let OPEN_LATERAL_MENU:String = "OPEN_LATERAL_MENU"

    static let OPEN_UPLOAD_VIDEO_VIEW:String = "OPEN_UPLOAD_VIDEO_VIEW"
    static let OPEN_LIVE_STREAMING_VIEW:String = "OPEN_LIVE_STREAMING_VIEW"
    static let OPEN_UPCOMING_EVENT_VIEW:String = "OPEN_UPCOMING_EVENT_VIEW"

}
