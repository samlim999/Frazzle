//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Kingfisher
import AlamofireImage
import Alamofire
import Toast_Swift
import AVKit
import Async


class TimelineCell: UITableViewCell {

    @IBOutlet var imgPlayerBackground: UIImageView!
    @IBOutlet var imgLoadingAnimation: UIImageView!
    @IBOutlet var imgLoadingBackground: UIImageView!
    @IBOutlet var btnPlayStop: UIButton!

    @IBOutlet var imgBottomLine: UIImageView!

    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblFavoritesCount: UILabel!

    @IBOutlet var videoView: UIView!
    @IBOutlet var viewVideoPlayer: VideoPlayerView!
    @IBOutlet var imgPosterFrame: UIImageView!
    @IBOutlet var btnFullScreen: UIButton!

    private var player: AVPlayer!
    private var avPlayerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem!

    @IBOutlet var lblPostTitle: UILabel!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnFavorite: UIButton!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var btnMuteVideo: UIButton!

    private var imgPlaceHolder: UIImage!

    private var playerBackgroundImageUrl: NSURL!
    
    private var imageCache: AutoPurgingImageCache?

    private var post: Post!
    private var type: C.TabType?

    private var steamingURL: NSURL!
    private var videoUrlChanged: Bool = false
    private var performingTransition: Bool = false

    private var shouldStopRotating: Bool = false
    private var isLoadingLaunched: Bool = false
    private var shouldPlay: Bool = false
    private var isPlaying: Bool = false

    private var cellSetup: Bool = false

    private var animationDuration: Double = 0.5

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.post = Post()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell() {
        if (!self.cellSetup) {
            self.cellSetup = true

            self.imgPlaceHolder = UIImage(named: "ImageLogoLogin")

            self.setupListeners()
            self.setupPlayer()
            self.setupViews()
        }
    }

    func setPost(post: Post) {

        self.post = post

        self.setupCell()

        self.bindInfo()
        self.bindProfileImage()
        self.bindPosterFrame()
        self.bindVideo()

    }

    func setTabType(type: C.TabType) {
        self.type = type

        self.imgBottomLine.backgroundColor = ThemeUtil.getAccentColor(type)
    }

    func setImageCache(imageCache: AutoPurgingImageCache) {
        self.imageCache = imageCache
    }

    private func setupListeners() {
        self.btnLike.addTarget(self, action: #selector(TimelineCell.btnLikeClick(_:)), forControlEvents: .TouchUpInside)
        self.btnFavorite.addTarget(self, action: #selector(TimelineCell.btnFavoriteClick(_:)), forControlEvents: .TouchUpInside)
        self.btnShare.addTarget(self, action: #selector(TimelineCell.sharePost(_:)), forControlEvents: .TouchUpInside)
        self.btnProfile.addTarget(self, action: #selector(TimelineCell.openProfile(_:)), forControlEvents: .TouchUpInside)
        self.btnMuteVideo.addTarget(self, action: #selector(TimelineCell.changeVideoSoundStatus(_:)), forControlEvents: .TouchUpInside)
        self.btnFullScreen.addTarget(self, action: #selector(TimelineCell.openVideoInFullScreen(_:)), forControlEvents: .TouchUpInside)

        self.btnPlayStop.addTarget(self, action: #selector(TimelineCell.btnPlayStopTouch(_:)), forControlEvents: .TouchUpInside)

    }

    private func setupViews(){
        if(UserManager.isUserLoggedIn()){
            btnFavorite.hidden = false
            btnLike.hidden = false

            changeLikeButtonImage(PostsManager.getIndividualPostLike(String(post.postId)))
            changeFavoriteButtonImage(PostsManager.getIndividualPostFavorite(String(post.postId)))
        }else{
            btnFavorite.hidden = true
            btnLike.hidden = true
        }
    }

    func btnLikeClick(sender: UIButton){
        PostsManager.setIndividualPostLike(String(post.postId), value: !(PostsManager.getIndividualPostLike(String(post.postId))))

        changeLikeButtonImage(PostsManager.getIndividualPostLike(String(post.postId)))
    }

    func btnFavoriteClick(sender: UIButton){
        PostsManager.setIndividualPostFavorite(String(post.postId), value: !(PostsManager.getIndividualPostFavorite(String(post.postId))))

        changeFavoriteButtonImage(PostsManager.getIndividualPostFavorite(String(post.postId)))
    }

    func btnPlayStopTouch(sender: UIButton){
        playVideoWithoutReset(!isPlaying)
    }

    func playerDidFinishPlaying(note: NSNotification) {
        self.player.seekToTime(kCMTimeZero)
        print("Video Finished")
    }

    func changeVideoSoundStatus(sender: UIButton) {
        player.muted = !player.muted
        if (player.muted) {
            btnMuteVideo.setImage(UIImage(named: "btn-video-unmute"), forState: .Normal)
            btnMuteVideo.setImage(UIImage(named: "btn-video-unmute"), forState: .Selected)

        } else {
            btnMuteVideo.setImage(UIImage(named: "btn-video-mute"), forState: .Normal)
            btnMuteVideo.setImage(UIImage(named: "btn-video-mute"), forState: .Selected)

        }
    }

    func openVideoInFullScreen(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let view = appDelegate.window?.rootViewController {
            if let navigation = view as? UINavigationController {

                print (post.getVideoUrl());
//                let player = AVPlayer(URL: post.getVideoUrl())
                
                let playerViewController = VideoPlayerViewController()
                playerViewController.setPost(post)
                playerViewController.setUrl(post.getVideoUrl().absoluteString)
                playerViewController.setBlurredURL(self.playerBackgroundImageUrl)
                
//                let playerViewController = AVPlayerViewController()
//                playerViewController.player = player
                
                navigation.presentViewController(playerViewController, animated: true) {
//                    let bgView = UIImageView()
//                    bgView.af_setImageWithURL(self.playerBackgroundImageUrl);
//                    bgView.frame = (playerViewController.contentOverlayView?.frame)!
//                    playerViewController.contentOverlayView?.addSubview(bgView)
//                    
//
//                    playerViewController.contentOverlayView?.sendSubviewToBack(bgView)
//                    playerViewController.contentOverlayView!.backgroundColor = UIColor.whiteColor()
//                    let request: NSURLRequest = NSURLRequest(URL: self.playerBackgroundImageUrl)
//                    
//                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) in
//                        if error == nil {
//                            let bgImg: UIImage
//                            
//                            bgImg = UIImage(data: data!)!
//                            
//                            playerViewController.contentOverlayView!.backgroundColor = UIColor(patternImage: bgImg)
//                            
//                        }
//                    })
                    
                    
//                    playerViewController.player!.play()
                }

            }
        }
    }

    func btnFunctionOnlyAvailableToLoggedInUsers(sender: UIButton) {
        makeToast("You must be logged in to use this feature")
    }

    func openProfile(sender: UIButton) {
        if let user = UserManager.getUserByID(post.userName) {

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let view = appDelegate.window?.rootViewController {
                if let navigation = view as? UINavigationController {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)

                    let profile = storyboard.instantiateViewControllerWithIdentifier("ProfileView") as! ProfileViewController

                    profile.setUser(user)

                    navigation.pushViewController(profile, animated: true)

                }
            }
        }
    }

    func sharePost(sender: UIButton) {
        let textToShare = post.title + " - " + post.postUrl + " #frazzletv"

        if let url = NSURL(string: post.postUrl) {
            let objectsToShare = [textToShare, url]
            let activity = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            activity.popoverPresentationController?.sourceView = sender

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

            if let view = appDelegate.window?.rootViewController {
                view.presentViewController(activity, animated: true, completion: nil)
            }
        }
    }

    func bindInfo() {
        lblPostTitle.text = post.description
        lblUsername.text = post.userName
        lblFavoritesCount.text = (post.likeCount as NSNumber).stringValue

        if(UserManager.isUserLoggedIn()){
            changeFavoriteButtonImage(PostsManager.getIndividualPostLike(String(post.postId)))
            changeLikeButtonImage(PostsManager.getIndividualPostFavorite(String(post.postId)))
        }
    }

    func changeFavoriteButtonImage(favorite:Bool){
        btnFavorite.setImage(UIImage(named: favorite ? "icon-favorite-full-red" : "icon-favorite-empty-red"), forState: .Normal)
    }

    func changeLikeButtonImage(like:Bool){
        btnLike.setImage(UIImage(named: like ? "icon-like-full-yellow" : "icon-like-empty-yellow"), forState: .Normal)
    }

    func bindProfileImage() {
        let imageUrl: NSURL = NSURL(string: post.userPicUrl)!

        let size = CGSize(width: 90.0, height: 90.0)
        let imageFilter = AspectScaledToFillSizeCircleFilter(size: size)

        imgUser.af_setImageWithURL(
                imageUrl,
                placeholderImage: nil,
                filter: imageFilter,
                imageTransition: .CrossDissolve(0.2)
                )

        /*if let _ = imageCache {
            let profileImage = imageCache!.imageForRequest(
                    URLRequest,
                    withAdditionalIdentifier: "circle"
                    )
            if let _ = profileImage{
                imgUser.image = profileImage
            }else {
                let downloader = ImageDownloader()

                downloader.downloadImage(URLRequest: URLRequest) { response in

                    if let image = response.result.value {
                        self.imageCache!.addImage(
                                image,
                                forRequest: URLRequest,
                                withAdditionalIdentifier: "circle"
                                )

                        self.imgUser.image =  imageFilter.filter(image)
                    }
                }
            }
        }else{

            imgUser.af_setImageWithURL(
                    imageUrl,
                    placeholderImage: nil,
                    filter: imageFilter,
                    imageTransition: .CrossDissolve(0.2)
                    )
        }
        imgUser.layer.drawsAsynchronously = true*/
    }

    func bindPosterFrame() {

        Async.background() {
            self.imgPosterFrame.hidden = false
            self.imgPosterFrame.alpha = 1.0
        }

        let posterFrameImageUrl: NSURL = NSURL(string: post.thumbnailUrl)!

        imgPosterFrame.af_setImageWithURL(
                posterFrameImageUrl,
                placeholderImage: imgPlaceHolder
                )
        
        playerBackgroundImageUrl = NSURL(string: post.blurredThumbUrl)!

        imgPlayerBackground.af_setImageWithURL(
                playerBackgroundImageUrl,
                placeholderImage: imgPlaceHolder
                )



        /*imgPosterFrame.layer.drawsAsynchronously = true

        imgPosterFrame.alpha = 1.0
        imgPosterFrame.hidden = false
        
        let URLRequest = NSURLRequest(URL:imageUrl)
        
        if let _ = imageCache {
            let profileImage = imageCache!.imageForRequest(
                URLRequest,
                withAdditionalIdentifier: "posterFrame"
            )
            if let _ = profileImage{
                imgUser.image = profileImage
            }else {
                let downloader = ImageDownloader()
                
                downloader.downloadImage(URLRequest: URLRequest) { response in
                    
                    if let image = response.result.value {
                        self.imageCache!.addImage(
                            image,
                            forRequest: URLRequest,
                            withAdditionalIdentifier: "posterFrame"
                        )
                        
                        self.imgUser.image =  image
                    }
                }
            }
        }else{
            
            imgUser.af_setImageWithURL(
                imageUrl,
                placeholderImage: nil,
                filter: nil,
                imageTransition: .CrossDissolve(0.2)
            )
        }
        imgUser.layer.drawsAsynchronously = true*/
    }

    func setupPlayer() {
        self.player = viewVideoPlayer.player
    }

    func bindVideo() {
        if self.player == nil {
            setupPlayer()
        }

        Async.background {
            self.steamingURL = self.post.getVideoUrl()
            self.videoUrlChanged = true
        }
    }

    func play() {
        changePosterFrameVisibility(true, playVideo: true)
    }

    func stop() {
        self.shouldPlay = false
        self.isPlaying = false
        self.playVideo(false)
    }

    func pause() {
        self.shouldPlay = false
        self.isPlaying = false
        changePosterFrameVisibility(false, playVideo: false)
    }

    func playVideo(playVideo: Bool) {
        Async.background {
            if let _ = self.player {
                if (playVideo) {
                    self.shouldPlay = true
                    self.player.seekToTime(kCMTimeZero)
                    self.loadVideoAssetAsync(self.steamingURL)
                    self.videoUrlChanged = false
                } else {
                    if ((self.player.rate != 0) && (self.player.error == nil)) {
                        self.player.pause()
                    }

                }
            }
        }
    }

    func playVideoWithoutReset(playVideo: Bool) {
        Async.background {
            if let _ = self.player {
                if (playVideo) {
                    self.shouldPlay = true
                    self.player.play()
                    self.isPlaying = true
                } else {
                    if ((self.player.rate != 0) && (self.player.error == nil)) {
                        self.player.pause()
                    }
                    self.isPlaying = false

                }
            }
        }
    }

    func loadVideoAssetAsync(url: NSURL) {
        let asset = AVURLAsset(URL: url, options: nil)
        // load values for track keys
        let keys = ["tracks", "duration"]

        asset.loadValuesAsynchronouslyForKeys(keys, completionHandler: {
            () -> Void in
            // Loop through and check to make sure keys loaded
            var keyStatusError: NSError?
            for key in keys {
                var error: NSError?
                let keyStatus: AVKeyValueStatus = asset.statusOfValueForKey(key, error: &error)
                if keyStatus == .Failed {
                    //let userInfo = [NSUnderlyingErrorKey: key]
                    //keyStatusError = NSError(domain: MovieSourceErrorDomain, code: MovieSourceAssetFailedToLoadKeyValueErrorCode, userInfo: userInfo)
                    print("Failed to load key: \(key), error: \(error)")
                } else if keyStatus != .Loaded {
                    print("Warning: Ignoring key status: \(keyStatus), for key: \(key), error: \(error)")
                }
            }

            if keyStatusError == nil {
                self.playerItem = AVPlayerItem(asset: asset)
                self.player.replaceCurrentItemWithPlayerItem(self.playerItem)

                if(self.shouldPlay) {
                    self.showLoadingAnimation(false,delay:self.animationDuration)
                    self.isPlaying = true
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.currentItem)

                    Async.main() {
                        self.player.play()
                    }


                }

            } else {
                print("Failed to load asset: \(keyStatusError)")
            }
        })
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.imgLoadingAnimation.rotate360Degrees(completionDelegate: self)
        }
    }

    func changePosterFrameVisibility(hidden: Bool, playVideo: Bool) {

        if (self.imgPosterFrame.hidden != hidden) && (!self.performingTransition) {

            if (!self.isLoadingLaunched) {
                self.showLoadingAnimation(true,delay:0)
            }

            self.performingTransition = true

            let transitionOptions = UIViewAnimationOptions.CurveEaseOut

            var initialPosterFrameAlpha: CGFloat
            var endingPosterFrameAlpha: CGFloat
            if (hidden) {
                initialPosterFrameAlpha = 1.0
                endingPosterFrameAlpha = 0.0
            } else {
                initialPosterFrameAlpha = 0.0
                endingPosterFrameAlpha = 1.0
            }

            let endingPosterFrameHiddenState = hidden

            self.imgPosterFrame.alpha = initialPosterFrameAlpha
            self.imgPosterFrame.hidden = false

            UIView.animateWithDuration(self.animationDuration, delay: 0.0, options: transitionOptions, animations: {
                self.imgPosterFrame.alpha = endingPosterFrameAlpha
            },
                    completion: {
                        (completed: Bool) in

                        if (completed) {
                            self.imgPosterFrame.alpha = endingPosterFrameAlpha
                            self.imgPosterFrame.hidden = endingPosterFrameHiddenState
                        }

                        self.playVideo(playVideo)
                        self.performingTransition = false

                    })
        }
    }

    func showLoadingAnimation(showLoading:Bool,delay:Double){
        self.isLoadingLaunched = showLoading

        Async.main(after:delay) {
            self.imgLoadingAnimation.hidden = !showLoading
            self.imgLoadingBackground.hidden = !showLoading
            self.shouldStopRotating = !showLoading

            if(showLoading) {
                self.imgLoadingAnimation.rotate360Degrees(1.0, completionDelegate: self)
            }
        }
    }
}
