//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class MediaManager {

    private static let KEY_MEDIA_JSON:String = "KEY_MEDIA_JSON";

    static func setJson(json:String){
        SimplePersistence.setString(KEY_MEDIA_JSON, value: json)
    }

    static func getJson()->String{
        return SimplePersistence.getString(KEY_MEDIA_JSON)
    }

    static func getAsList()->Array<Media>{
        return try! Media.fromJsonToList(self.getJson())
    }

    static func getMediaById(id:Int)->Media?{
        for var media:Media in getAsList() {
            if(media.mediaId == id) {
                return media
            }
        }
        return nil
    }

    static func getLastAdded()->Media?{
        var list = getAsList()
        if(!list.isEmpty) {
            return list.last
        }
        return nil
    }

    static func addNewMedia(media:Media){
        var list = getAsList()
        list.append(media)
        setJson(Media.toJsonFromList(list))
    }

    static func postMetadataToServer(mediaMetadata:MediaMetadata) {
        MediaService.postMediaMetadata(mediaMetadata)
    }

    static func postFileToServer(media:Media, filePath:String) {
        MediaService.uploadMedia(media, filePath:filePath)
    }
}
