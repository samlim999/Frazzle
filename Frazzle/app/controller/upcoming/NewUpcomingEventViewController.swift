//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices
import ActionSheetPicker_3_0

class NewUpcomingEventViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate {
    @IBOutlet var viewLoading: UIView!

    @IBOutlet var viewImage: UIImageView!
    @IBOutlet var viewVideoPlayer: VideoPlayerView!
    @IBOutlet var fieldSection: UITextField!
    @IBOutlet var fieldTitle: UITextField!
    @IBOutlet var fieldDescription: UITextView!
    @IBOutlet var fieldStartDate: UITextField!
    @IBOutlet var fieldStartTime: UITextField!
    
    @IBOutlet var btnSelectMedia: UIButton!
    @IBOutlet var btnPlayStopSelectedVideo: UIButton!
    @IBOutlet var btnUpload: UIButton!

    @IBOutlet var viewModal: UIView!

    @IBOutlet var btnDismissModal: UIButton!
    @IBOutlet var btnRecordVideo: UIButton!
    @IBOutlet var btnSelectVideo: UIButton!

    public var backgroundColor:UIColor?

    private var manager:MediaManager?
    
    private var postMetadata:PostMetadata?
    private var mediaMetadata:MediaMetadata?
    private var media:Media?

    private var player:AVPlayer?
    private var videoPath:String=""

    private var pickermode : NSInteger?
    private var datePicker : UIDatePicker?
    private var timePicker : UIDatePicker?
    
    var pickOption:[String]!
    @IBOutlet weak var mainSubView: UIView!

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

        fieldStartTime.delegate = self
        fieldStartDate.delegate = self
        
        fieldStartDate.tag = 12
        fieldStartTime.tag = 11
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        fieldSection.inputView = pickerView
        fieldSection.readonly = true

        if(UserManager.getLoggedInUser()!.isShop()){
            pickOption = ["HERBS", "VIBES", "TUNES", "SHOPS"]
        }else{

            pickOption = ["HERBS", "VIBES", "TUNES"]
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaReadyToBeUploaded(_:)), name:C.MEDIA_INFO_DOWNLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaNotReadyToBeUploaded(_:)), name:C.MEDIA_INFO_NOT_DOWNLOADED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.postUploaded(_:)), name:C.POST_INFO_UPLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.postCannotToBeUploaded(_:)), name:C.POST_INFO_NOT_UPLOADED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaUploaded(_:)), name:C.MEDIA_UPLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.mediaCannotBeUploaded(_:)), name:C.MEDIA_NOT_UPLOADED, object: nil)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = player {
            player!.removeObserver(self, forKeyPath: "loadedTimeRanges")
            player!.removeObserver(self, forKeyPath: "status")
        }
    }
    
    //called when the date/time picker called.
//    internal func onDidChangeDate (sender: UIDatePicker) {
//        
//        //date format
//        let dateFormatter: NSDateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        //get the date string applied date format
//        let startDate : NSString = dateFormatter.stringFromDate(sender.date)
//        fieldStartDate.text = startDate as String
//    }
//    
//    internal func onDidChangeTime (sender: UIDatePicker) {
//        
//        //date format
//        let timeFormatter: NSDateFormatter = NSDateFormatter()
//        timeFormatter.dateFormat = "hh:mm"
//        
//        //get the date string applied date format
//        let startDate : NSString = timeFormatter.stringFromDate(sender.date)
//        fieldStartTime.text = startDate as String
//    }
    
    @IBAction func onDidChangeDateTime(sender: AnyObject) {
        let timeFormatter: NSDateFormatter = NSDateFormatter()
        
        if pickermode == 1 {
            timeFormatter.dateFormat = "hh:mm"
            let startTime : NSString = timeFormatter.stringFromDate(sender.date)
            fieldStartTime.text = startTime as String
        } else if pickermode == 2 {
            timeFormatter.dateFormat = "MM/dd/yyyy"
            let startDate : NSString = timeFormatter.stringFromDate(sender.date)
            fieldStartDate.text = startDate as String
        } else {
            
        }
    }
    
    func setupListeners(){
        btnSelectMedia.addTarget(self, action: #selector(openModal(_:)), forControlEvents: .TouchUpInside)
        btnPlayStopSelectedVideo.addTarget(self, action: #selector(playStopVideo(_:)), forControlEvents: .TouchUpInside)

        btnUpload.addTarget(self, action: #selector(uploadVideo(_:)), forControlEvents: .TouchUpInside)

        btnDismissModal.addTarget(self, action: #selector(dismissModal(_:)), forControlEvents: .TouchUpInside)

        btnRecordVideo.addTarget(self, action: #selector(recordVideo(_:)), forControlEvents: .TouchUpInside)
        btnSelectVideo.addTarget(self, action: #selector(selectVideo(_:)), forControlEvents: .TouchUpInside)
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
        }else {
            //show toast
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
        tryToUpload()
    }

    func tryToUpload(){

        if(validateData()) {

            mediaMetadata = MediaMetadata()
            mediaMetadata!.fileExtension = "mp4"
            mediaMetadata!.mediaType = C.MediaType.STATIC_VIDEO

            postMetadata = PostMetadata()

            switch fieldTitle.text! {
                case "HERBS":
                    postMetadata!.category = C.CategoryType.HERBS
                case "VIBES":
                    postMetadata!.category = C.CategoryType.VIBES
                case "TUNES":
                    postMetadata!.category = C.CategoryType.TUNES
                case "SHOPS":
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

    //textfield delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
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

    
    @IBAction func showTimePicker(sender: AnyObject) {
        let datePicker = ActionSheetDatePicker(title: "Time:", datePickerMode: UIDatePickerMode.Time, selectedDate: NSDate(), target: self, action: #selector(NewUpcomingEventViewController.timePicked(_:)), origin: sender.superview!!.superview)
        
        datePicker.minuteInterval = 20
        datePicker.timeZone = NSTimeZone.localTimeZone()
        datePicker.showActionSheetPicker()
    }
    
    
    @IBAction func showDatePicker(sender: AnyObject) {
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = -18
        let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        components.year = -150
        let maxDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!

        let datePicker = ActionSheetDatePicker (title: "Date:", datePickerMode: UIDatePickerMode.Date, selectedDate: NSDate(), target: self, action: #selector(NewUpcomingEventViewController.datePicked(_:)), origin: sender.superview!!.superview)
        datePicker.timeZone = NSTimeZone.localTimeZone()
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.showActionSheetPicker()
    }

    func timePicked(obj: NSDate) {
        let  formatter = NSDateFormatter()
        formatter.dateFormat = "hh mm a"
        self.fieldStartTime.text = formatter.stringFromDate(obj)
    }

    func datePicked(obj: NSDate) {
        let  formatter = NSDateFormatter()
        formatter.dateFormat = "MM dd, yyyy"
        self.fieldStartDate.text = formatter.stringFromDate(obj)
    }

}
