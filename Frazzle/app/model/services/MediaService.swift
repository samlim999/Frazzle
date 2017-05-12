//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator

class MediaService : Service{

    static let POST_MEDIA_SERVICE_URL_SEGMENT:String = "/media";
    static let GET_MEDIA_INFO_SERVICE_URL_SEGMENT:String = "/media/";

    static func postMediaMetadata(mediaMetadata:MediaMetadata) {

        if(UserManager.isUserLoggedIn()){
            showNetworkIndicator()
            let user = UserManager.getLoggedInUser()

            let username = user!.username
            let password = user!.password

            let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
            let base64Credentials = credentialData.base64EncodedStringWithOptions([])

            var headers = C.HEADERS
            headers["Authorization"] = "Basic \(base64Credentials)"

            Alamofire.request(.POST, C.URL_SERVER+POST_MEDIA_SERVICE_URL_SEGMENT, headers: headers, parameters: [:], encoding: .Custom({
                (convertible, params) in
                let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                mutableRequest.HTTPBody = mediaMetadata.toJson().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

                print(mediaMetadata.toJson())

                return (mutableRequest, nil)
            }))
            .responseString {
                response in

                hideNetworkIndicator()
                
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization

                if (response.result.isSuccess) {

                    if let JSON: String = response.result.value {
                        print("JSON: \(JSON)")

                        var media: Media?
                        do {
                            media = try Media.fromJson(JSON)

                        } catch _ {

                        }

                        if let _ = media {
                            //print("JSON: \(TimeLineItem.toJsonFromList(users!))")

                            MediaManager.addNewMedia(media!)
                            NSNotificationCenter.defaultCenter().postNotificationName(C.MEDIA_INFO_DOWNLOADED, object: self)
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName(C.MEDIA_INFO_NOT_DOWNLOADED, object: self)
                        }

                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(C.MEDIA_INFO_NOT_DOWNLOADED, object: self)
                    }
                }else {
                    NSNotificationCenter.defaultCenter().postNotificationName(C.MEDIA_INFO_NOT_DOWNLOADED, object: self)
                }
            }
        }
    }

    
    
    /*
     "upload_info": {
     "url": "https://frazzle-images.s3.amazonaws.com/",
     "fields": {
     "key": "5fdd11ed072141f6b8f1de39a2784c96/be25f580d63c4ed593b4e99a403bf756.mp4",
     "signature": "kwqusBW35rYhwqh8Tlv4S4y61eQ=",
     "AWSAccessKeyId": "AKIAIW2VGOJI5BX3375A",
     "policy": "eyJjb25kaXRpb25zIjogW3siYWNsIjogInB1YmxpYy1yZWFkIn0sIFsiY29udGVudC1sZW5ndGgtcmFuZ2UiLCA1MTIsIDIwOTcxNTIwMF0sIHsiYnVja2V0IjogImZyYXp6bGUtaW1hZ2VzIn0sIHsia2V5IjogIjVmZGQxMWVkMDcyMTQxZjZiOGYxZGUzOWEyNzg0Yzk2L2JlMjVmNTgwZDYzYzRlZDU5M2I0ZTk5YTQwM2JmNzU2LnBuZyJ9XSwgImV4cGlyYXRpb24iOiAiMjAxNi0wNi0yMlQwMjoxMDowOFoifQ==",
     "acl": "public-read"
     }
     },
     "uploader_id": 24604687193867308,
     "broadcast_info": null,
     "created_at": "2016-06-22T02:00:08+00:00",
     "media_id": 24604687193867310,
     "updated_at": "2016-06-22T02:00:08+00:00",
     "s3_url": "https://frazzle-images.s3.amazonaws.com/5fdd11ed072141f6b8f1de39a2784c96/be25f580d63c4ed593b
     
     */
    
    static func uploadMedia(media:Media, filePath:String) {

        let S3Key: String = media.uploadInfo.fields.key
        let S3ACL: String = media.uploadInfo.fields.acl
        let S3AccessKey: String = media.uploadInfo.fields.AWSAccessKeyId
        let S3Policy: String = media.uploadInfo.fields.policy
        let S3Signature: String = media.uploadInfo.fields.signature

        print (media.uploadInfo.toJson())
        
        let S3FileURL: NSURL = NSURL(fileURLWithPath: filePath)
        let S3FileName: String = S3FileURL.lastPathComponent!

        var S3ContentType: String
      
        if(S3FileName.lowercaseString.containsString(".mov")){
            S3ContentType = "video/quicktime"
        }else{
            S3ContentType = "video/mp4"
        }

        let S3URL: String = media.uploadInfo.url
//        let S3URL: String = media.s3url
        print ("s3 url : ", media.s3url);
        print ("uploadinfo url : ", media.uploadInfo.url)

        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [:];

        Alamofire.upload(.POST, S3URL,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: S3Key.dataUsingEncoding(NSUTF8StringEncoding,
                            allowLossyConversion: false)!, name :"key")
                    multipartFormData.appendBodyPart(data: S3ACL.dataUsingEncoding(NSUTF8StringEncoding,
                            allowLossyConversion: false)!, name :"acl")
                    multipartFormData.appendBodyPart(data: S3AccessKey.dataUsingEncoding(NSUTF8StringEncoding,
                            allowLossyConversion: false)!, name :"AWSAccessKeyId")
                    multipartFormData.appendBodyPart(data: S3Policy.dataUsingEncoding(NSUTF8StringEncoding,
                            allowLossyConversion: false)!, name :"Policy")
                    multipartFormData.appendBodyPart(data: S3Signature.dataUsingEncoding(NSUTF8StringEncoding,
                            allowLossyConversion: false)!, name :"Signature")
                    
                    multipartFormData.appendBodyPart(fileURL: S3FileURL, name: "file", fileName: S3FileName, mimeType: S3ContentType)
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        print("Success : ")
//                        upload.responseJSON { request, response, JSON, error in
//                            
//                            
//                        }
                        upload.responseString(completionHandler: { response in
                            debugPrint(response)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(C.MEDIA_UPLOADED, object: self)
                        })
                        
//                        upload.responseJSON { response in
//                            debugPrint(response)
//                        }
                        
                        
                    case .Failure(let encodingError):
                        print("Failure")

                        /*print(response.request)  // original URL request
                        print(response.response) // URL response
                        //print(response.data)     // server data
                        print(response.result)   // result of response serialization*/

                        debugPrint(encodingError)

                        NSNotificationCenter.defaultCenter().postNotificationName(C.MEDIA_NOT_UPLOADED, object: self)
                    }
                })
    }


    /*
    "url": "https://frazzle-images.s3.amazonaws.com/",
    "fields": {
      "key": "5fdd11ed072141f6b8f1de39a2784c96/be25f580d63c4ed593b4e99a403bf756.mp4",
      "signature": "kwqusBW35rYhwqh8Tlv4S4y61eQ=",
      "AWSAccessKeyId": "AKIAIW2VGOJI5BX3375A",
      "policy": "eyJjb25kaXRpb25zIjogW3siYWNsIjogInB1YmxpYy1yZWFkIn0sIFsiY29udGVudC1sZW5ndGgtcmFuZ2UiLCA1MTIsIDIwOTcxNTIwMF0sIHsiYnVja2V0IjogImZyYXp6bGUtaW1hZ2VzIn0sIHsia2V5IjogIjVmZGQxMWVkMDcyMTQxZjZiOGYxZGUzOWEyNzg0Yzk2L2JlMjVmNTgwZDYzYzRlZDU5M2I0ZTk5YTQwM2JmNzU2LnBuZyJ9XSwgImV4cGlyYXRpb24iOiAiMjAxNi0wNi0yMlQwMjoxMDowOFoifQ==",
      "acl": "public-read"
    }
    */
}
