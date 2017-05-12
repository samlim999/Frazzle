//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator

class Service {

    static func showNetworkIndicator() {
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
    }

    static func hideNetworkIndicator() {
        NetworkActivityIndicatorManager.sharedManager.isEnabled = false
    }

    static func printResponse(response:Response<String,NSError>){
        if C.DEBUG {
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization

            if let JSON: String = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }

    static func printError(response:Response<String,NSError>){
        if C.DEBUG {
            print(response.request)  // original URL request
            print(response.response) // URL response

            if let error = response.result.error {
                print(error)
            }
        }
    }

    static func buildHeaders(user:User)->[String: String]?{
        let username = user.username
        let password = user.password

        let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])

        var headers = C.HEADERS
        headers["Authorization"] = "Basic \(base64Credentials)"

        return headers
    }
}
