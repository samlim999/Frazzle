//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate {
    @IBOutlet var viewLoading: UIView!

    @IBOutlet var viewVideoPlayer: VideoPlayerView!
    @IBOutlet var fieldSection: UITextField!
    @IBOutlet var fieldTitle: UITextField!
    @IBOutlet var fieldDescription: UITextView!
    
    @IBOutlet var btnSelectMedia: UIButton!
    @IBOutlet var btnPlayStopSelectedVideo: UIButton!
    @IBOutlet var btnUpload: UIButton!

    @IBOutlet var viewModal: UIView!

    @IBOutlet var btnDismissModal: UIButton!
    @IBOutlet var btnRecordVideo: UIButton!
    @IBOutlet var btnSelectVideo: UIButton!

    var backgroundColor:UIColor?

    private var manager:MediaManager?
    
    private var postMetadata:PostMetadata?
    private var mediaMetadata:MediaMetadata?
    private var media:Media?

    private var player:AVPlayer?
    private var videoPath:String=""

    var pickOption:[String]!

    private var isPlaying:Bool = false

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let _ = backgroundColor {
            viewVideoPlayer.backgroundColor = backgroundColor!
            fieldSection.textColor = backgroundColor!
            btnUpload.setTitleColor(backgroundColor!, forState: UIControlState.Normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupListeners()

        fieldTitle.delegate = self;
        fieldDescription.delegate = self;

        fieldDescription.text = "Description..."
        fieldDescription.textColor = UIColor.lightGrayColor()

        let pickerView = UIPickerView()
        pickerView.delegate = self
        fieldSection.inputView = pickerView
        fieldSection.readonly = true

        if(UserManager.getLoggedInUser()!.isShop()){
            pickOption = ["HERBS", "VIBES", "TUNES", "SHOP"]
        }else{

            pickOption = ["HERBS", "VIBES", "TUNES"]
        }


        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaReadyToBeUploaded(_:)), name:C.MEDIA_INFO_DOWNLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaNotReadyToBeUploaded(_:)), name:C.MEDIA_INFO_NOT_DOWNLOADED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.postUploaded(_:)), name:C.POST_INFO_UPLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.postCannotToBeUploaded(_:)), name:C.POST_INFO_NOT_UPLOADED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaUploaded(_:)), name:C.MEDIA_UPLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaCannotBeUploaded(_:)), name:C.MEDIA_NOT_UPLOADED, object: nil)

        
////steven : post media data after request post
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.tryToUpload(_:)), name:C.USER_POSTS_DOWNLOADED, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = player {
            player!.removeObserver(self, forKeyPath: "loadedTimeRanges")
            player!.removeObserver(self, forKeyPath: "status")
        }
    }

    func setupListeners(){
        btnSelectMedia.addTarget(self, action: #selector(UploadViewController.openModal(_:)), forControlEvents: .TouchUpInside)
        btnPlayStopSelectedVideo.addTarget(self, action: #selector(UploadViewController.playStopVideo(_:)), forControlEvents: .TouchUpInside)

        btnUpload.addTarget(self, action: #selector(UploadViewController.uploadVideo(_:)), forControlEvents: .TouchUpInside)

        btnDismissModal.addTarget(self, action: #selector(UploadViewController.dismissModal(_:)), forControlEvents: .TouchUpInside)

        btnRecordVideo.addTarget(self, action: #selector(UploadViewController.recordVideo(_:)), forControlEvents: .TouchUpInside)
        btnSelectVideo.addTarget(self, action: #selector(UploadViewController.selectVideo(_:)), forControlEvents: .TouchUpInside)
    }

    func setupPlayer(){

        if videoPath != "" {
            let videoURL: NSURL = NSURL(string: "file://" + videoPath)!
            let playerItem = AVPlayerItem(URL: videoURL)

            if let _ = player {

                player!.replaceCurrentItemWithPlayerItem(playerItem)
            } else {

                player = viewVideoPlayer.player

                player!.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions(), context: nil)
                player!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)

                player!.replaceCurrentItemWithPlayerItem(playerItem)
            }

            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player!.currentItem)
        }
    }

    func playerDidFinishPlaying(notification: NSNotification){
        setupPlayer()
        isPlaying = false
    }

    func openModal(sender: UIButton){
        viewModal.hidden = false
    }

    func playStopVideo(sender: UIButton){
        if let _ = player {
            switch player!.status {
            case AVPlayerStatus.Unknown:()
                player!.pause()
                isPlaying = true
            case AVPlayerStatus.ReadyToPlay:
                if(isPlaying){
                    player!.pause()
                }else {
                    player!.play()
                }
                isPlaying = !isPlaying
            case AVPlayerStatus.Failed:()
                player!.pause()
                isPlaying = true
            }
        }
    }

    func dismissModal(sender: UIButton){
        viewModal.hidden = true
    }

    func selectVideo(sender: UIButton){
        selectVideo()
        dismissModal(sender)
    }

    func recordVideo(sender: UIButton){
        recordVideo()
        dismissModal(sender)
    }

    func selectVideo(){
        selectOrRecordVideo(true)
    }

    func recordVideo(){
        selectOrRecordVideo(false)
    }

    func selectOrRecordVideo(select:Bool){
        let cameraController = UIImagePickerController()


        if(select) {
            cameraController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }else{
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
        }


        if UIImagePickerController.isSourceTypeAvailable(cameraController.sourceType) == false {

            //show toast
            switch cameraController.sourceType{
            case UIImagePickerControllerSourceType.Camera: ()
            case UIImagePickerControllerSourceType.PhotoLibrary: ()
            default:()
            }
        }else {

            cameraController.delegate = self
            cameraController.mediaTypes = [kUTTypeMovie as String]
            cameraController.allowsEditing = true
            cameraController.videoMaximumDuration = 60.0
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
    }


    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)

        let videoURL:NSURL = info["UIImagePickerControllerMediaURL"] as! NSURL
        //"UIImagePickerControllerReferenceURL" -> assets-library://asset/asset.mov?id=BB71C9C1-67A5-4B7D-ACCA-F8EC6298A137&ext=mov
        videoPath = videoURL.path! //"file://" + videoURL.path!

        setupPlayer()
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func mediaReadyToBeUploaded(notification: NSNotification){
        media = MediaManager.getLastAdded()
        if let _ = media {
            postMetadata!.mediaId = media!.mediaId

            uploadMedia()

            //change ui
            self.viewLoading.hidden = true;
            
        }else {
            //show toast
            
            self.view.makeToast("Something went wrong, try again later please")
        }

    }

    func mediaNotReadyToBeUploaded(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(),{

            self.viewLoading.hidden = true

            self.view.makeToast("Something went wrong, try again later please")
        })
    }

    func postUploaded(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(),{

            self.viewLoading.hidden = true

            self.view.makeToast("Thank you for submiting your video")
        })
    }

    func postCannotToBeUploaded(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(),{
            self.viewLoading.hidden = true

            self.view.makeToast("Something went wrong, try again later please")
        })
    }

    func mediaUploaded(notification: NSNotification){
        uploadPost()
    }

    func mediaCannotBeUploaded(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(),{
            self.viewLoading.hidden = true

            self.view.makeToast("Something went wrong, try again later please")
        })
    }

    
    func uploadVideo(sender: UIButton){
//        PostService.requestPosts(UserManager.getLoggedInUser()!)
        tryToUpload()
    }

    func tryToUpload (){

        if(validateData()) {

            mediaMetadata = MediaMetadata()
            mediaMetadata!.fileExtension = "mp4"
            mediaMetadata!.mediaType = C.MediaType.STATIC_VIDEO

            postMetadata = PostMetadata()

            switch fieldSection.text! {
                case "HERBS":
                    postMetadata!.category = C.CategoryType.HERBS
                case "VIBES":
                    postMetadata!.category = C.CategoryType.VIBES
                case "TUNES":
                    postMetadata!.category = C.CategoryType.TUNES
                case "SHOP":
                    postMetadata!.category = C.CategoryType.SHOPS
                default:
                    postMetadata!.category = C.CategoryType.HERBS
            }

            postMetadata!.postType = C.PostType.REGULAR
            postMetadata!.title = fieldTitle.text!
            postMetadata!.description = fieldDescription.text!

            viewLoading.hidden = false

            uploadMediaMetadata()
        }
    }

    func validateData()->Bool{

        if(!fieldSection.hasText())||(fieldSection.text!.trim()==""){
            self.view.makeToast("Select a section")
            return false
        }

        if(!fieldTitle.hasText())||(fieldTitle.text!.trim()==""){
            self.view.makeToast("Title required")
            return false
        }

        if(!fieldDescription.hasText())||((fieldDescription.text?.trim()=="")||(fieldDescription.text?.trim() == "Description...")){
            self.view.makeToast("Description required")
            return false
        }

        if(videoPath==""){
            self.view.makeToast("Select or record a video")
            return false
        }

        return true
    }

    func uploadMediaMetadata(){
        MediaManager.postMetadataToServer(mediaMetadata!)
    }

    func uploadPost(){
        PostsManager.postMetadataToServer(postMetadata!)
    }

    func uploadMedia(){
        MediaManager.postFileToServer(media!, filePath:videoPath)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        /*if let _ = player {

            switch player!.status {
            case AVPlayerStatus.Unknown:
                print("Unknown")
            case AVPlayerStatus.ReadyToPlay:
                print("ReadyToPlay")
            case AVPlayerStatus.Failed:
                print("Failed")
            }
        }*/
    }

    func textViewDidBeginEditing(textView:UITextView){

        if (textView.text == "Description..."){
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(textView:UITextView){

        if (textView.text == ""){
            textView.text = "Description..."
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            self.tryToUpload()
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.fieldTitle {
            self.fieldTitle.resignFirstResponder()
            self.fieldDescription.becomeFirstResponder()
        }

        return true
    }

    func textViewShouldReturn(textView: UITextView) -> Bool {
        if textView == self.fieldDescription {
            self.fieldDescription.resignFirstResponder()
            self.tryToUpload()
        }

        return true
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fieldSection.text = pickOption[row]
    }

}
