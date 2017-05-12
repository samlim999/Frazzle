//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlayerView : UIView {

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    var player: AVPlayer {
        let playerLayer = layer as? AVPlayerLayer
        if playerLayer!.player == nil {

            playerLayer!.player = AVPlayer()
        }
        playerLayer!.drawsAsynchronously = true
        return playerLayer!.player!
    }

}
