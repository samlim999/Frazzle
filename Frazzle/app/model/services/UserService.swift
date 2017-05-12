//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator

class UserService : Service{

    static let GET_USERS_SERVICE_URL_SEGMENT:String = "/users?page=1&per_page=100"
    static let GET_SHOPS_SERVICE_URL_SEGMENT:String = "/users?page=1&per_page=100&type=Shops"

    static let GET_LOGIN_SERVICE_URL_SEGMENT:String = "/users/me"

    static let GET_FOLLOWERS_SERVICE_URL_SEGMENT:String = "/users/{user_id}/followers"

    static let POST_FOLLOWING_SERVICE_URL_SEGMENT:String = "/users/{user_id}/followers"
    static let DELETE_FOLLOWING_SERVICE_URL_SEGMENT:String = "/users/{user_id}/followers"

    static let GET_FOLLOWING_SERVICE_URL_SEGMENT:String = "/users/{user_id}/following"


    static func loginUser(user:User) {

        showNetworkIndicator()

        Alamofire.request(.GET, C.URL_SERVER+GET_LOGIN_SERVICE_URL_SEGMENT, headers: buildHeaders(user))
        .responseString {
            response in

            hideNetworkIndicator()

            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization

            var notification:String = C.USER_NOT_LOGGED_IN

            if (response.result.isSuccess) {
                if let JSON: String = response.result.value {
                    //print("JSON: \(JSON)")

                    var backendUser: User?
                        backendUser = User.fromJson(JSON)

                        if let _ = backendUser {

                            backendUser!.password = user.password

                            UserManager.setLoginUser(backendUser!)
                            UserManager.uploadToken()
                            UserService.requestUsers()
                            
                            notification = C.USER_LOGGED_IN
                        }

                }
            }

            NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
        }
    }

    static func requestUsers() {

        var notification:String = C.USERS_NOT_DOWNLOADED

        if(UserManager.isUserLoggedIn()) {
            showNetworkIndicator()
            let user = UserManager.getLoggedInUser()

            let username = user!.username
            let password = user!.password

            let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
            let base64Credentials = credentialData.base64EncodedStringWithOptions([])

            var headers = C.HEADERS
            headers["Authorization"] = "Basic \(base64Credentials)"

            Alamofire.request(.GET, C.URL_SERVER + GET_USERS_SERVICE_URL_SEGMENT, headers: headers)
            .responseString {
                response in

                hideNetworkIndicator()

                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization



                if (response.result.isSuccess) {
                    if let JSON: String = response.result.value {
                        print("JSON: \(JSON)")

                        var users: Array<User>?
                        do {
                            users = try User.fromJsonToList(JSON)

                            if let _ = users {
                                UserManager.setUsersByType(users!)

                                notification = C.USERS_DOWNLOADED
                                NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
                            }
                        } catch _ {

                        }
                    }
                }


            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
    }

    static func requestShops() {

        var notification:String = C.SHOPS_NOT_DOWNLOADED

            showNetworkIndicator()

            let username = "franciscothompson"
            let password = "pass1"

            let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
            let base64Credentials = credentialData.base64EncodedStringWithOptions([])

            var headers = C.HEADERS
            headers["Authorization"] = "Basic \(base64Credentials)"

            Alamofire.request(.GET, C.URL_SERVER + GET_SHOPS_SERVICE_URL_SEGMENT, headers: headers)
            .responseString {
                response in

                hideNetworkIndicator()

                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization



                if (response.result.isSuccess) {
                    if let JSON: String = response.result.value {
                        print("JSON: \(JSON)")

                        var users: Array<User>?
                        do {
                            users = try User.fromJsonToList(JSON)

                            if let _ = users {
                                UserManager.setUsersByType(users!)

                                notification = C.SHOPS_DOWNLOADED
                            }
                        } catch _ {

                        }
                    }
                }


            }
        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
    }

    static func requestFollowers() {

        var notification:String = C.FOLLOWERS_NOT_DOWNLOADED

        if(UserManager.isUserLoggedIn()) {
            showNetworkIndicator()

            let user = UserManager.getLoggedInUser()

            Alamofire.request(.GET, C.URL_SERVER + GET_FOLLOWERS_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{user_id}", withString: user!.username), headers:  buildHeaders(user!))
            .responseString {
                response in

                hideNetworkIndicator()

                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization



                if (response.result.isSuccess) {
                    if let JSON: String = response.result.value {
                        //print("JSON: \(JSON)")

                        var users: Array<User>?
                        do {
                            users = try User.fromJsonToList(JSON)

                            if let _ = users {
                                UserManager.setFollowers(users!)

                                notification = C.FOLLOWERS_DOWNLOADED
                                NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
                            }
                        } catch _ {

                        }
                    }
                }
            }
        }

        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
    }

    static func requestFollowing() {

        if(UserManager.isUserLoggedIn()) {
            showNetworkIndicator()

            let user = UserManager.getLoggedInUser()

            Alamofire.request(.GET, C.URL_SERVER + GET_FOLLOWING_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{user_id}", withString: user!.username), headers:  buildHeaders(user!))
            .responseString {
                response in

                hideNetworkIndicator()

                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization

                var notification:String = C.FOLLOWING_NOT_DOWNLOADED

                if (response.result.isSuccess) {
                    if let JSON: String = response.result.value {
                        //print("JSON: \(JSON)")

                        var users: Array<User>?
                        do {
                            users = try User.fromJsonToList(JSON)

                            if let _ = users {
                                UserManager.setFollowing(users!)

                                notification = C.FOLLOWING_DOWNLOADED
                                NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)
                            }
                        } catch _ {

                        }
                    }
                }

                NSNotificationCenter.defaultCenter().postNotificationName(notification, object: self)

            }
        }
    }

    static func postFollowing(userToFollow:User) {

        if(UserManager.isUserLoggedIn()) {
            showNetworkIndicator()

            let user = UserManager.getLoggedInUser()

            Alamofire.request(.POST, C.URL_SERVER + POST_FOLLOWING_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{user_id}", withString: userToFollow.username), headers:  buildHeaders(user!))
            .responseString {
                response in

                hideNetworkIndicator()

                if (response.result.isSuccess){
                    NSNotificationCenter.defaultCenter().postNotificationName(C.FOLLOWING_ADDED, object: self)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName(C.FOLLOWING_NOT_ADDED, object: self)
                }
            }
        }
    }

    static func deleteFollowing(userToFollow:User) {

        if(UserManager.isUserLoggedIn()) {
            showNetworkIndicator()

            let user = UserManager.getLoggedInUser()

            Alamofire.request(.DELETE, C.URL_SERVER + DELETE_FOLLOWING_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{user_id}", withString: userToFollow.username), headers: buildHeaders(user!))
            .responseString {
                response in

                hideNetworkIndicator()

                if (response.result.isSuccess){
                    NSNotificationCenter.defaultCenter().postNotificationName(C.FOLLOWING_DELETED, object: self)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName(C.FOLLOWING_NOT_DELETED, object: self)
                }
            }
        }
    }
}
