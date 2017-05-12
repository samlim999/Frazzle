//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift


class ThemeUtil {

    static func getMainColor(type:C.TabType)->UIColor{

        switch type {
            case C.TabType.HOME_HERBS:
                 return UIColor(rgba: C.COLOR_HOME_HERBS)
            case C.TabType.HOME_SHOPS:
                return UIColor(rgba: C.COLOR_HOME_SHOPS)
            case C.TabType.HOME_TUNES:
                return UIColor(rgba: C.COLOR_HOME_TUNES)
            case C.TabType.HOME_VIBES:
                return UIColor(rgba: C.COLOR_HOME_VIBES)
            case C.TabType.SHOPS:
                return UIColor(rgba: C.COLOR_SHOPS)
            case C.TabType.USERS_PROFILES:
                return UIColor(rgba: C.COLOR_PROFILES)
            case C.TabType.USERS_FOLLOWERS:
                return UIColor(rgba: C.COLOR_PROFILES)
            case C.TabType.USERS_FOLLOWING:
                return UIColor(rgba: C.COLOR_PROFILES)
            case C.TabType.LIVE:
                return UIColor(rgba: C.COLOR_LIVE)
            case C.TabType.SEARCH:
                return UIColor(rgba: C.COLOR_SEARCH)
        }
    }

    static func getAccentColor(type:C.TabType)->UIColor{

        switch type {
        case C.TabType.HOME_HERBS:
            return UIColor(rgba: C.COLOR_ACCENT_HOME_HERBS)
        case C.TabType.HOME_SHOPS:
            return UIColor(rgba: C.COLOR_ACCENT_HOME_SHOPS)
        case C.TabType.HOME_TUNES:
            return UIColor(rgba: C.COLOR_ACCENT_HOME_TUNES)
        case C.TabType.HOME_VIBES:
            return UIColor(rgba: C.COLOR_ACCENT_HOME_VIBES)
        case C.TabType.SHOPS:
            return UIColor(rgba: C.COLOR_ACCENT_SHOPS)
        case C.TabType.USERS_PROFILES:
            return UIColor(rgba: C.COLOR_ACCENT_PROFILES)
        case C.TabType.USERS_FOLLOWERS:
            return UIColor(rgba: C.COLOR_ACCENT_PROFILES)
        case C.TabType.USERS_FOLLOWING:
            return UIColor(rgba: C.COLOR_ACCENT_PROFILES)
        case C.TabType.LIVE:
            return UIColor(rgba: C.COLOR_ACCENT_LIVE)
        case C.TabType.SEARCH:
            return UIColor(rgba: C.COLOR_ACCENT_SEARCH)

        }
    }

    static func getWhiteColor()->UIColor{
        return UIColor(rgba: C.COLOR_WHITE)
    }

    static func getTopTabFontColor()->UIColor{
        return UIColor(rgba: C.COLOR_GREY_ALUMINUM)
    }

    static func getTabTitle(type:C.TabType)->String{

    switch type {
        case C.TabType.HOME_HERBS:
            return C.BOTTOM_TAB_NAME_HOME
        case C.TabType.HOME_SHOPS:
            return C.BOTTOM_TAB_NAME_HOME
        case C.TabType.HOME_TUNES:
            return C.BOTTOM_TAB_NAME_HOME
        case C.TabType.HOME_VIBES:
            return C.BOTTOM_TAB_NAME_HOME
        case C.TabType.SHOPS:
            return C.BOTTOM_TAB_NAME_SHOPS
        case C.TabType.USERS_PROFILES:
            return C.BOTTOM_TAB_NAME_PEOPLE
        case C.TabType.USERS_FOLLOWERS:
            return C.BOTTOM_TAB_NAME_PEOPLE
        case C.TabType.USERS_FOLLOWING:
            return C.BOTTOM_TAB_NAME_PEOPLE
        case C.TabType.LIVE:
            return C.BOTTOM_TAB_NAME_LIVE
        case C.TabType.SEARCH:
            return C.BOTTOM_TAB_NAME_SEARCH

    }
}

}
