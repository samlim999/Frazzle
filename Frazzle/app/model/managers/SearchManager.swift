//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class SearchManager {

    static func search(query:String) {
        PostsManager.searchOnServer(query)
        UserManager.seachOnServer(query)
    }

    func getPostsFromSearch()->Array<Post>{
        return PostsManager.getPostsSearchAsList()
    }

    func getShopsFromSearch()->Array<User>{
        return UserManager.getShopsSearchResults()
    }

    func getUsersFromSearch()->Array<User>{
        return UserManager.getUsersFromSearch()
    }
}
