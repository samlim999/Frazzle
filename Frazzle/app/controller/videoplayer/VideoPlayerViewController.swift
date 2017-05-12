//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit
class VideoPlayerViewController: AVPlayerViewController {
//class VideoPlayerViewController: UIViewController, UINavigationControllerDelegate {
    private var post:Post?
    private var postID:String?
    private var url:String?
    private var blurredImgURL : NSURL?
    
    private var bgView : UIImageView?
    private var bgView1 : UIImageView?
    private var bgView2 : UIImageView?
    
    var blurImg : UIImage!
    
    //image data
    private var imgData : NSData?
    
    func setPost(post:Post){
        self.post = post
    }

    func setPostID(postID:String){
        self.postID = postID
    }

    func setBlurredURL(url:NSURL){
        self.blurredImgURL = url
    }

    func setUrl(url:String){
        self.url = url
    }

    override func viewDidLoad() {
        if let _ = post {
            loadVideo(post!.getVideoUrl().absoluteString)
        }
        else if let _ = postID {
            PostsManager.fetchIndividualPost(postID!)

            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayerViewController.postDownloaded(_:)), name:C.NOTIFICATION_POST_DOWNLOADED, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayerViewController.postNotDownloaded(_:)), name:C.NOTIFICATION_POST_NOT_DOWNLOADED, object: nil)
            
        }
        else if let _ = url {
            loadVideo(url!)
        }
        
//        imgData = NSData(contentsOfURL:blurredImgURL!)
      
//        blurImg = UIImage (data: imgData!)!
        
        //default background before loading video view
//        bgView = UIImageView(frame:self.view.bounds)
//        bgView!.image = blurImg
//        bgView!.contentMode = UIViewContentMode.ScaleToFill
        
        //up to vide view
        bgView1 = UIImageView(frame:self.view.bounds)
        bgView1!.af_setImageWithURL(blurredImgURL!);
        bgView1!.contentMode = UIViewContentMode.ScaleToFill

        //down to video view
        bgView2 = UIImageView(frame:self.view.bounds)
        bgView2!.af_setImageWithURL(blurredImgURL!);
        bgView2!.contentMode = UIViewContentMode.ScaleToFill

//        self.contentOverlayView?.addSubview(bgView!)
        self.contentOverlayView?.addSubview(bgView1!)
        self.contentOverlayView?.addSubview(bgView2!)
        
//        self.view.sendSubviewToBack(bgView!)
        self.view.sendSubviewToBack(bgView1!)
        self.view.sendSubviewToBack(bgView2!)
    }
//
//    //crop image
//    func cropToBounds(image: UIImage, x : Float, y : Float, width: Float, height: Float) -> UIImage {
//        
//        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
//        
////        let contextSize: CGSize = contextImage.size
//        
//        let posX: CGFloat = CGFloat(x)
//        let posY: CGFloat = CGFloat(y)
//        let cgwidth: CGFloat = CGFloat(width)
//        let cgheight: CGFloat = CGFloat(height)
//        
////        // See what size is longer and create the center off of that
////        if contextSize.width > contextSize.height {
////            posX = ((contextSize.width - contextSize.height) / 2)
////            posY = 0
////            cgwidth = contextSize.height
////            cgheight = contextSize.height
////        } else {
////            posX = 0
////            posY = ((contextSize.height - contextSize.width) / 2)
////            cgwidth = contextSize.width
////            cgheight = contextSize.width
////        }
//        
//        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
//        
//        
//        // Create bitmap image from context using the rect
//        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
//        
//        // Create a new image based on the imageRef and rotate back to the original orientation
//        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
//        
//        return image
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //set the frame of your imageView here to automatically adopt screen size changes (e.g. by rotation or splitscreen)
        
        let rect : CGRect
        
        rect = self.videoBounds
        
        if rect.origin.y < 5 {
            bgView1?.hidden = true;
            bgView2?.hidden = true;
        } else {
            bgView1?.hidden = false;
            bgView2?.hidden = false;
            bgView1?.frame = CGRectMake(0, 0, self.view.frame.size.width, rect.origin.y)
            bgView2?.frame = CGRectMake(rect.origin.x , rect.origin.y + rect.size.height, self.view.frame.size.width, self.view.frame.size.height - rect.size.height - rect.origin.y);
        }
    }
    
     func postDownloaded(notification: NSNotification){
        PostsManager.getIndividualPost()
    }

     func postNotDownloaded(notification: NSNotification){
        self.post = PostsManager.getIndividualPost()
    }

    private func loadVideo(videoUrl:String){
        self.player = AVPlayer (URL:NSURL(string:videoUrl)!)
        player?.play()
    }
}
