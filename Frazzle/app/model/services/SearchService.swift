//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator

class SearchService : Service{

    static let GET_SEARCH_SERVICE_URL_SEGMENT:String = "/search?page=1&per_page=100";

/*
query: required (string)
Search term. Make sure you percent-encode it.

target: (string - default: Posts)
Specify what kind of object to return. Currently supports "Posts", "Users", "People", "Shops".

post_category: (string - default: All)
Specify a filter for Post category. E.g. post_category=TUNES.

page: (integer - default: 1 - minimum: 1)
Support for pagination of the results. Specifies the page number to retrieve.

per_page: (integer - default: 20 - maximum: 100)
Specifies the number of post items on each page.
Example: If page = 3 and per_page = 20, then the result set will be from 41 to 60.

*/

    static func postsSearch(query:String) {
        SearchService.generalSearch(query,type:C.SearchType.Posts,category:nil)
    }

    static func usersSearch(query:String) {
//        SearchService.generalSearch(query,type:C.SearchType.USERS,category:"TOP")
        SearchService.generalSearch(query,type:C.SearchType.Users,category:nil)
    }

    static func shopsSearch(query:String) {
        SearchService.generalSearch(query,type:C.SearchType.Shops,category:nil)
    }

    static func generalSearch(query:String,type: C.SearchType, category:String?) {

        showNetworkIndicator()

        let user = "franciscothompson"
        let password = "pass1"
        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])

        var headers = C.HEADERS
        headers["Authorization"] = "Basic \(base64Credentials)"

        var queryString = "&query="+query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!+"&target="+type.rawValue
        if let _ = category {
            queryString += "&post_category=" + category!
        }

        Alamofire.request(.GET, C.URL_SERVER+GET_SEARCH_SERVICE_URL_SEGMENT+queryString, headers: headers)
        .responseString {
            response in

            hideNetworkIndicator()

            print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result.value)   // result of response serialization

            if (response.result.isSuccess) {
                if let JSON: String = response.result.value {
                    print (JSON);
                    switch type {
                    case C.SearchType.Shops:
                        processShopsSearch(JSON)
                    case C.SearchType.Users:
                        processUsersSearch(JSON)
                    case C.SearchType.Posts:
                        processPostsSearch(JSON)
                    default:()
                    }
                }else{
                    sendNotDownloadedNotification(type)
                }
            }else{
                sendNotDownloadedNotification(type)
            }


        }


    }

    static func sendNotDownloadedNotification(type:C.SearchType){
        switch type {
        case C.SearchType.Shops:
            NSNotificationCenter.defaultCenter().postNotificationName(C.SEARCH_SHOPS_NOT_DOWNLOADED, object: self)
        case C.SearchType.Users:
            NSNotificationCenter.defaultCenter().postNotificationName(C.SEARCH_USERS_NOT_DOWNLOADED, object: self)
        case C.SearchType.Posts:
            NSNotificationCenter.defaultCenter().postNotificationName(C.SEARCH_POSTS_NOT_DOWNLOADED, object: self)
        default:()
        }
    }

    static func processShopsSearch(json:String){
        var notification = C.SEARCH_SHOPS_DOWNLOADED
        do {
            try UserManager.setShopsFromSearch(User.fromJsonToList(json))
        } catch _ {
            notification = C.SEARCH_SHOPS_NOT_DOWNLOADED
        }


        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
    }

    static func processUsersSearch(json:String){
        var notification = C.SEARCH_USERS_DOWNLOADED
        do {
            try UserManager.setUsersFromSearch(User.fromJsonToList(json))
        } catch _ {
            notification = C.SEARCH_USERS_NOT_DOWNLOADED
        }

        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
    }

    static func processPostsSearch(json:String){
        var notification = C.SEARCH_POSTS_DOWNLOADED
        do {
            try TimelineManager.setPostFromSearch(Post.fromJsonToList(json))
        } catch _ {
            notification = C.SEARCH_POSTS_NOT_DOWNLOADED
        }

        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
    }
}
