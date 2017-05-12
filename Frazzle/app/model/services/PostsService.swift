//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import Alamofire


class PostService : Service {

    static let GET_USER_POST_SERVICE_URL_SEGMENT:String = "/users/{user_id}/posts"
    static let GET_INDIVIDUAL_POST_SERVICE_URL_SEGMENT:String = "/posts/{post_id}"
    static let POST_METADATA_SERVICE_URL_SEGMENT:String = "/posts"
    static let POST_BROADCAST_EVENT_SERVICE_URL_SEGMENT:String = "/posts/{post_id}/broadcast_events"


    static func requestPosts(user:User) {
        showNetworkIndicator()

        let localUser = UserManager.getLoggedInUser()

        Alamofire.request(.GET, C.URL_SERVER+GET_USER_POST_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{user_id}", withString: user.username), headers: buildHeaders(localUser!))
        .responseString {
            response in

            hideNetworkIndicator()

            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization

            if (response.result.isSuccess){

                if let JSON:String = response.result.value {
                    var posts: Array<Post>?
                    do {
                        posts = try Post.fromJsonToList(JSON)

                        if let _ = posts {
                            PostsManager.setUserPosts(user,posts:posts!)

                            NSNotificationCenter.defaultCenter().postNotificationName(C.USER_POSTS_DOWNLOADED, object: self)
                        }else{
                            NSNotificationCenter.defaultCenter().postNotificationName(C.USER_POSTS_NOT_DOWNLOADED, object: self)
                        }
                    } catch _ {
                        posts = nil
                        NSNotificationCenter.defaultCenter().postNotificationName(C.USER_POSTS_NOT_DOWNLOADED, object: self)
                    }

                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName(C.USER_POSTS_NOT_DOWNLOADED, object: self)
                }
            }else{
                NSNotificationCenter.defaultCenter().postNotificationName(C.USER_POSTS_NOT_DOWNLOADED, object: self)
            }
        }
    }

    static func fechtIndividualPost(postID:String) {
        showNetworkIndicator()

        let localUser = UserManager.getLoggedInUser()

        Alamofire.request(.GET, C.URL_SERVER+GET_INDIVIDUAL_POST_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{post_id}", withString: postID), headers: buildHeaders(localUser!))
        .responseString {
            response in

            hideNetworkIndicator()

            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization

            if (response.result.isSuccess){

                if let JSON:String = response.result.value {
                    var post: Post?
                    do {
                        post = try Post.fromJson(JSON)

                        if let _ = post {
                            PostsManager.setIndividualPost(post!)

                            NSNotificationCenter.defaultCenter().postNotificationName(C.NOTIFICATION_POST_DOWNLOADED, object: self)
                            NSNotificationCenter.defaultCenter().postNotificationName(C.NOTIFICATION_POST_DOWNLOADED_APP_DELEGATE, object: self)

                        }else{
                            NSNotificationCenter.defaultCenter().postNotificationName(C.NOTIFICATION_POST_NOT_DOWNLOADED, object: self)
                        }
                    } catch _ {
                        NSNotificationCenter.defaultCenter().postNotificationName(C.NOTIFICATION_POST_NOT_DOWNLOADED, object: self)
                    }

                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName(C.NOTIFICATION_POST_NOT_DOWNLOADED, object: self)
                }
            }else{
                NSNotificationCenter.defaultCenter().postNotificationName(C.NOTIFICATION_POST_NOT_DOWNLOADED, object: self)
            }
        }
    }

    static func postPostMetadata(postMetadata:PostMetadata) {

        showNetworkIndicator()

        let user = UserManager.getLoggedInUser()

        let username = user!.username
        let password = user!.password
        
        let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])

        var headers = C.HEADERS
        headers["Authorization"] = "Basic \(base64Credentials)"

        Alamofire.request(.POST, C.URL_SERVER+POST_METADATA_SERVICE_URL_SEGMENT, headers: headers, parameters: [:], encoding: .Custom({
            (convertible, params) in
            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            mutableRequest.HTTPBody = postMetadata.toJson().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
print ("postMedaData:", postMetadata.toJson())
            return (mutableRequest, nil)
        }))
        .responseString {
            response in

            hideNetworkIndicator()

            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization

            if let JSON:String = response.result.value {
                print("JSON: \(JSON)")

                var post:Post?
                do {
                    post = try Post.fromJson(JSON)
                    if let _ = post{
                        PostsManager.addNewPost(post!)
                        //print("JSON: \(TimeLineItem.toJsonFromList(users!))")

                        //var manager:MediaManager = MediaManager()
                        //manager.addNewMedia(post)
                        NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_POST_INFO_UPLOADED, object: self)
                    }else{
                        NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_POST_INFO_NOT_UPLOADED, object: self)
                    }

                } catch _ {
                    NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_POST_INFO_NOT_UPLOADED, object: self)
                }
            }else{
                NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_POST_INFO_NOT_UPLOADED, object: self)
            }
        }
    }

    static func postBroadcastEvent(post:Post, broadcastEvent:BroadcastEvent) {

        showNetworkIndicator()

        let user = UserManager.getLoggedInUser()

        let username = user!.username
        let password = user!.password

        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])

        var headers = C.HEADERS
        headers["Authorization"] = "Basic \(base64Credentials)"

        Alamofire.request(.POST, C.URL_SERVER+POST_BROADCAST_EVENT_SERVICE_URL_SEGMENT.stringByReplacingOccurrencesOfString("{post_id}", withString: String(post.postId)), headers: headers, parameters: [:], encoding: .Custom({
            (convertible, params) in
            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            mutableRequest.HTTPBody = broadcastEvent.toJson().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

            return (mutableRequest, nil)
        }))
        .responseString {
            response in

            hideNetworkIndicator()

            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization

            if let JSON:String = response.result.value {
                //print("JSON: \(JSON)")

                var broadcastEventResponse:BroadcastEventResponse?
                do {
                    broadcastEventResponse = try BroadcastEventResponse.fromJson(JSON)
                    if let _ = broadcastEventResponse{


                        //print("JSON: \(TimeLineItem.toJsonFromList(users!))")

                        //var manager:MediaManager = MediaManager()
                        //manager.addNewMedia(post)
                        NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_EVENT_SEND, object: self)
                    }else{
                        NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_EVENT_NOT_SEND, object: self)
                    }

                } catch _ {
                    NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_EVENT_NOT_SEND, object: self)
                }
            }else{
                NSNotificationCenter.defaultCenter().postNotificationName(C.BROADCAST_EVENT_NOT_SEND, object: self)
            }
        }
    }
}
