//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import WowzaGoCoderSDK
import WowzaGoCoderSDK.WZMediaConfig
import Async

class LiveBroadcastViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, WZStatusCallback, WZVideoSink, WZAudioSink {

    let SDKSampleSavedConfigKey = "SDKSampleSavedConfigKey"
    let SDKSampleAppLicenseKey = "GSDK-8642-0000-A80D-0E6C-3FF7"
    //let BlackAndWhiteEffectKey = "BlackAndWhiteKey"

    @IBOutlet weak var broadcastButton:UIButton!
    @IBOutlet weak var settingsButton:UIButton!
    @IBOutlet weak var switchCameraButton:UIButton!
    @IBOutlet weak var torchButton:UIButton!
    @IBOutlet weak var micButton:UIButton!

    @IBOutlet var viewLoading: UIView!

    @IBOutlet var fieldSection: UITextField!
    @IBOutlet var fieldTitle: UITextField!
    @IBOutlet var fieldDescription: UITextView!

    @IBOutlet var btnPost: UIButton!

    @IBOutlet var viewForm: UIView!

    @IBOutlet var btnDismissModal: UIButton!
    @IBOutlet var btnCloseModal: UIButton!

    var backgroundColor:UIColor?

    private var postMetadata:PostMetadata?
    private var mediaMetadata:MediaMetadata?
    private var broadcastInfo:BroadcastInfo?
    private var broadcastEvent:BroadcastEvent?
    private var post:Post?
    private var media:Media?


    var pickOption:[String]!

    var goCoder:WowzaGoCoder?
    var goCoderConfig:WowzaConfig!

    var receivedGoCoderEventCodes = Array<WZEvent>()

    var blackAndWhiteVideoEffect = false

    var goCoderRegistrationChecked = false

    var readyToBroadcast:Bool = false
    var broadCasting:Bool = false


    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Reload any saved data
        //blackAndWhiteVideoEffect = NSUserDefaults.standardUserDefaults().boolForKey(BlackAndWhiteEffectKey)
        WowzaGoCoder.setLogLevel(.Default)

        // Log version and platform info
        //print("WowzaGoCoderSDK version =\n major: \(WZVersionInfo.majorVersion())\n minor: \(WZVersionInfo.minorVersion())\n revision: \(WZVersionInfo.revision())\n build: \(WZVersionInfo.buildNumber())\n string: \(WZVersionInfo.string())\n verbose string: \(WZVersionInfo.verboseString())")

        //print("Platform Info:\n\(WZPlatformInfo.string())")

        if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
            self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError)
        }

        setupListeners()
        setupFields()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        /*let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")

        UIViewController.attemptRotationToDeviceOrientation()*/

        super.viewWillAppear(animated)

        if let _ = backgroundColor {
            fieldSection.textColor = backgroundColor!
            btnPost.setTitleColor(backgroundColor!, forState: UIControlState.Normal)
        }

        self.initGoCoder()

    }

    override func viewWillDisappear(animated: Bool) {
        self.goCoder?.cameraPreview?.stopPreview()

        if goCoder?.status.state == .Running {
            goCoder?.endStreaming(self)

            let broadcastEvent = BroadcastEvent()
            broadcastEvent.event = C.BroadcastEventType.PUBLISH.rawValue
            PostsManager.postBroadcastEventToServer(post!, broadcastEvent:broadcastEvent)

            postMetadata = nil
            mediaMetadata = nil
            broadcastInfo = nil
            post = nil
            media = nil

            readyToBroadcast = false
            broadCasting = false
        }

        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        goCoder?.cameraPreview?.previewLayer?.frame = view.bounds
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    /*override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }*/

    /*override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }*/

    func setupListeners(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveBroadcastViewController.broadcastSetupInServer(_:)), name:C.MEDIA_INFO_DOWNLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveBroadcastViewController.broadcastNotReadyToStart(_:)), name:C.MEDIA_INFO_NOT_DOWNLOADED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveBroadcastViewController.broadcastReadyToStart(_:)), name:C.BROADCAST_POST_INFO_UPLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveBroadcastViewController.broadcastNotReadyToStart(_:)), name:C.BROADCAST_POST_INFO_NOT_UPLOADED, object: nil)

        btnPost.addTarget(self, action: #selector(LiveBroadcastViewController.btnPostClick(_:)), forControlEvents: .TouchUpInside)
        broadcastButton.addTarget(self, action: #selector(LiveBroadcastViewController.broadcastButtonClick(_:)), forControlEvents: .TouchUpInside)

        btnCloseModal.addTarget(self, action: #selector(LiveBroadcastViewController.btnCloseModalClick(_:)), forControlEvents: .TouchUpInside)
        btnDismissModal.addTarget(self, action: #selector(LiveBroadcastViewController.btnCloseModalClick(_:)), forControlEvents: .TouchUpInside)
        
        btnDismissModal.addTarget(self, action: #selector(LiveBroadcastViewController.btnCloseModalClick(_:)), forControlEvents: .TouchUpInside)

        switchCameraButton.addTarget(self, action: #selector(LiveBroadcastViewController.didTapSwitchCameraButton(_:)), forControlEvents: .TouchUpInside)
        torchButton.addTarget(self, action: #selector(LiveBroadcastViewController.didTapTorchButton(_:)), forControlEvents: .TouchUpInside)
        micButton.addTarget(self, action: #selector(LiveBroadcastViewController.didTapMicButton(_:)), forControlEvents: .TouchUpInside)
    }

    func setupFields(){
        fieldTitle.delegate = self;
        fieldDescription.delegate = self;

        fieldDescription.text = "Description..."
        fieldDescription.textColor = UIColor.lightGrayColor()

        let pickerView = UIPickerView()
        pickerView.delegate = self
        fieldSection.inputView = pickerView
        fieldSection.readonly = true

        if(UserManager.getLoggedInUser()!.isShop()){
            pickOption = ["HERBS", "VIBES", "TUNES", "SHOPS"]
        }else{

            pickOption = ["HERBS", "VIBES", "TUNES"]
        }
    }

    func broadcastSetupInServer(notification: NSNotification){

        media = MediaManager.getLastAdded()
        if let _ = media {
            postMetadata!.mediaId = media!.mediaId

            PostsManager.postMetadataToServer(postMetadata!)

        }else {
            //show toast
        }
    }

    func broadcastReadyToStart(notification: NSNotification){
        readyToBroadcast = true
        viewLoading.hidden = true

        self.post = PostsManager.getLastNewPostAdded()
        
        if let _ = self.post {
            postMetadata!.mediaId = media!.mediaId

            let alert = UIAlertController(title: "Ready to broadcast", message: "Click REC when you are ready", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

            cleanForm()
        }else {
            //show toast
        }
    }

    func broadcastNotReadyToStart(notification: NSNotification){
        let alert = UIAlertController(title: "Alert", message: "We cannot go live this moment", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        //show message
        viewLoading.hidden = true
    }

    func btnPostClick(sender: UIButton){
        uploadMetadata()

    }

    func broadcastButtonClick(sender: UIButton){
        if(readyToBroadcast){
            if(broadCasting){
                didTapBroadcastButton(sender)
            }else{
                broadcastInfo = MediaManager.getLastAdded()?.broadcastInfo

                fullConfigGoCoder()

                didTapBroadcastButton(sender)
            }


        }else{
            viewForm.hidden = false
        }
    }

    func btnCloseModalClick(sender: UIButton){
        viewForm.hidden = true
        viewLoading.hidden = true
    }

    func cleanForm(){
        self.fieldSection.text = ""
        self.fieldDescription.text = ""
    }

    func uploadMediaMetadata(){
        MediaManager.postMetadataToServer(mediaMetadata!)
    }

    func uploadPost(){
        PostsManager.postMetadataToServer(postMetadata!)
    }

    func uploadMetadata(){

        if(validateData()) {

            mediaMetadata = MediaMetadata()
            mediaMetadata!.fileExtension = "mp4"
            mediaMetadata!.mediaType = C.MediaType.LIVE_VIDEO

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

            postMetadata!.postType = C.PostType.LIVE
            postMetadata!.title = fieldTitle.text!
            postMetadata!.description = fieldDescription.text!

            viewLoading.hidden = false

            uploadMediaMetadata()

            viewForm.hidden = true
            viewLoading.hidden = false
        }else{
            viewForm.hidden = false
            viewLoading.hidden = true
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

        return true
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
            self.uploadMetadata()
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
            self.uploadMetadata()
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

    private func initGoCoder(){
        if !goCoderRegistrationChecked {
            goCoderRegistrationChecked = true
            if let goCoderLicensingError = WowzaGoCoder.registerLicenseKey(SDKSampleAppLicenseKey) {
                self.showAlert("GoCoder SDK Licensing Error", error: goCoderLicensingError)
            }
            else {
                // Initialize the GoCoder SDK
                if let goCoder = WowzaGoCoder.sharedInstance() {
                    self.goCoder = goCoder

                    // Request camera and microphone permissions
                    WowzaGoCoder.requestPermissionForType(.Camera, response: { (permission) in
                        print("Camera permission is: \(permission == .Authorized ? "authorized" : "denied")")
                    })

                    WowzaGoCoder.requestPermissionForType(.Microphone, response: { (permission) in
                        print("Microphone permission is: \(permission == .Authorized ? "authorized" : "denied")")
                    })

                    self.goCoder?.registerVideoSink(self)
                    self.goCoder?.registerAudioSink(self)
                    configGoCoder()

                    // Specify the view in which to display the camera preview
                    self.goCoder?.cameraView = self.view

                    // Start the camera preview
                    self.goCoder?.cameraPreview?.previewGravity = WZCameraPreviewGravity.ResizeAspectFill
                    self.goCoder?.cameraPreview?.startPreview()
                }

                self.updateUIControls()

            }
        }
    }

    private func fullConfigGoCoder(){
        goCoderConfig = WowzaConfig()

        goCoderConfig.loadPreset(WZFrameSizePreset.Preset1280x720)
        goCoderConfig.broadcastVideoOrientation = WZBroadcastOrientation.AlwaysLandscape
        goCoderConfig.broadcastScaleMode = WZBroadcastScaleMode.AspectFit
        goCoderConfig.capturedVideoRotates = false
        goCoderConfig.videoPreviewRotates = false
        goCoderConfig.audioEnabled = true
        goCoderConfig.audioChannels = 2


        goCoderConfig.hostAddress = broadcastInfo?.host
        goCoderConfig.streamName = broadcastInfo?.streamName
        goCoderConfig.applicationName = broadcastInfo?.applicationName
        goCoderConfig.password = "U@ka7Yjao00"
        goCoderConfig.username = "test-broadcast"

        /*let savedConfigData = NSKeyedArchiver.archivedDataWithRootObject(goCoderConfig)
        NSUserDefaults.standardUserDefaults().setObject(savedConfigData, forKey: SDKSampleSavedConfigKey)
        NSUserDefaults.standardUserDefaults().synchronize()*/

        // Update the configuration settings in the GoCoder SDK
        if let _  = goCoder {
            goCoder?.config = goCoderConfig
            //blackAndWhiteVideoEffect = NSUserDefaults.standardUserDefaults().boolForKey(BlackAndWhiteKey)
        }
    }
    
    private func configGoCoder(){
        goCoderConfig = WowzaConfig()
        
        goCoderConfig.loadPreset(WZFrameSizePreset.Preset1280x720)
        goCoderConfig.broadcastVideoOrientation = WZBroadcastOrientation.AlwaysLandscape
        goCoderConfig.broadcastScaleMode = WZBroadcastScaleMode.AspectFill
        goCoderConfig.audioEnabled = true
        goCoderConfig.capturedVideoRotates = false
        goCoderConfig.videoPreviewRotates = false
        goCoderConfig.audioChannels = 2
        
        
        // Update the configuration settings in the GoCoder SDK
        if let _  = goCoder {
            goCoder?.config = goCoderConfig
        }
    }



    //MARK - UI Action Methods

    @IBAction func didTapBroadcastButton(sender:AnyObject?) {
        // Ensure the minimum set of configuration settings have been specified necessary to
        // initiate a broadcast streaming session
        if let configError = goCoder?.config.validateForBroadcast() {
            self.showAlert("Incomplete Streaming Settings", error: configError)
        } else {
            // Disable the U/I controls
            broadcastButton.enabled    = false
            torchButton.enabled        = false
            switchCameraButton.enabled = false
            //settingsButton.enabled     = false

            if goCoder?.status.state == .Running {
                goCoder?.endStreaming(self)

                let broadcastEvent = BroadcastEvent()
                broadcastEvent.event = C.BroadcastEventType.PUBLISH.rawValue
                PostsManager.postBroadcastEventToServer(post!, broadcastEvent:broadcastEvent)

                postMetadata = nil
                mediaMetadata = nil
                broadcastInfo = nil
                post = nil
                media = nil

                readyToBroadcast = false
                broadCasting = false
            }else {
                receivedGoCoderEventCodes.removeAll()
                goCoder?.startStreaming(self)

                broadCasting = true

                let broadcastEvent = BroadcastEvent()
                broadcastEvent.event = C.BroadcastEventType.PUBLISH.rawValue
                PostsManager.postBroadcastEventToServer(post!, broadcastEvent:broadcastEvent)

                let audioMuted = goCoder?.audioMuted ?? false
                micButton.setImage(UIImage(named: audioMuted ? "icon-no-mic-white" : "icon-mic-white"), forState: .Normal)
            }
        }
    }

    @IBAction func didTapSwitchCameraButton(sender:AnyObject?) {
        if let _ = self.goCoder {
            if let otherCamera = goCoder?.cameraPreview?.otherCamera() {
                if !otherCamera.supportsWidth(goCoderConfig.videoWidth) {
                    goCoderConfig.loadPreset(otherCamera.supportedPresetConfigs.last!.toPreset())
                    goCoder?.config = goCoderConfig
                }
                
                goCoder?.cameraPreview?.switchCamera()
                torchButton.setImage(UIImage(named: "icon-torch-white"), forState: .Normal)
                self.updateUIControls()
            }
        }
    }

    @IBAction func didTapTorchButton(sender:AnyObject?) {
        if let _ = self.goCoder {
            var newTorchState = goCoder?.cameraPreview?.camera?.torchOn ?? true
            newTorchState = !newTorchState
            goCoder?.cameraPreview?.camera?.torchOn = newTorchState
            torchButton.setImage(UIImage(named: newTorchState ? "icon-no-torch-white" : "icon-torch-white"), forState: .Normal)
        }
    }

    @IBAction func didTapMicButton(sender:AnyObject?) {
        if let _ = self.goCoder {
            var newMutedState = self.goCoder?.audioMuted ?? true
            newMutedState = !newMutedState
            goCoder?.audioMuted = newMutedState
            micButton.setImage(UIImage(named: newMutedState ? "icon-no-mic-white" : "icon-mic-white"), forState: .Normal)
        }
    }

    /*@IBAction func didTapSettingsButton(sender:AnyObject?) {
        if let settingsNavigationController = UIStoryboard(name: "GoCoderSettings", bundle: nil).instantiateViewControllerWithIdentifier("settingsNavigationController") as? UINavigationController {

            if let settingsViewController = settingsNavigationController.topViewController as? SettingsViewController {
                settingsViewController.addAllSections()
                settingsViewController.removeDisplaySection(.RecordVideoLocally)
                let viewModel = SettingsViewModel(sessionConfig: goCoderConfig)
                viewModel.supportedPresetConfigs = goCoder?.cameraPreview?.camera?.supportedPresetConfigs
                settingsViewController.viewModel = viewModel
            }


            self.presentViewController(settingsNavigationController, animated: true, completion: nil)
        }
    }*/

    func updateUIControls() {
        if self.goCoder?.status.state != .Idle && self.goCoder?.status.state != .Running {
            // If a streaming broadcast session is in the process of starting up or shutting down,
            // disable the UI controls
            self.broadcastButton.enabled    = false
            self.torchButton.enabled        = false
            self.switchCameraButton.enabled = false
            //self.settingsButton.enabled     = false
            self.micButton.hidden           = true
            self.micButton.enabled          = false
        }
        else {
            // Set the UI control state based on the streaming broadcast status, configuration,
            // and device capability
            self.broadcastButton.enabled    = true
            self.switchCameraButton.enabled = self.goCoder?.cameraPreview?.cameras?.count > 1
            self.torchButton.enabled        = self.goCoder?.cameraPreview?.camera?.hasTorch ?? false
            let isStreaming                 = self.goCoder?.isStreaming ?? false
            //self.settingsButton.enabled     = !isStreaming
            // The mic icon should only be displayed while streaming and audio streaming has been enabled
            // in the GoCoder SDK configuration setiings
            self.micButton.enabled          = isStreaming && self.goCoderConfig.audioEnabled
            self.micButton.hidden           = !self.micButton.enabled
        }
    }


    //MARK: - WZStatusCallback Protocol Instance Methods

    func onWZStatus(status: WZStatus!) {
        switch (status.state) {
        case .Idle:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.broadcastButton.setImage(UIImage(named: "icon-record-red"), forState: .Normal)
                self.updateUIControls()
            }

        case .Running:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.broadcastButton.setImage(UIImage(named: "icon-stop-record-red"), forState: .Normal)
                self.updateUIControls()
            }
        case .Stopping, .Starting:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.updateUIControls()
            }
        }

    }

    func onWZEvent(status: WZStatus!) {
        // If an event is reported by the GoCoder SDK, display an alert dialog describing the event,
        // but only if we haven't already shown an alert for this event

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if !self.receivedGoCoderEventCodes.contains(status.event) {
                self.receivedGoCoderEventCodes.append(status.event)
                self.showAlert("Live Streaming Event", status: status)
            }

            self.updateUIControls()
        }
    }

    func onWZError(status: WZStatus!) {
        // If an error is reported by the GoCoder SDK, display an alert dialog containing the error details
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.showAlert("Live Streaming Error", status: status)
            self.updateUIControls()
        }
    }


    //MARK: - WZVideoSink Protocol Methods
    func videoFrameWasCaptured(imageBuffer: CVImageBuffer, framePresentationTime: CMTime, frameDuration: CMTime) {

    }

    /*func videoFrameWasCaptured(imageBuffer: CVImageBuffer, framePresentationTime: CMTime, frameDuration: CMTime) {
        if goCoder != nil && goCoder!.isStreaming && blackAndWhiteVideoEffect {
            // convert frame to b/w using CoreImage tonal filter
            var frameImage = CIImage(CVImageBuffer: imageBuffer)
            if let grayFilter = CIFilter(name: "CIPhotoEffectTonal") {
                grayFilter.setValue(frameImage, forKeyPath: "inputImage")
                if let outImage = grayFilter.outputImage {
                    frameImage = outImage

                    let context = CIContext(options: nil)
                    context.render(frameImage, toCVPixelBuffer: imageBuffer)
                }

            }
        }
    }*/


    //MARK: - WZAudioSink Protocol Methods

    func audioLevelDidChange(level: Float) {
//        print("Audio level did change: \(level)");
    }


    //MARK: - Alerts

    func showAlert(title:String, status:WZStatus) {
        let alertController = UIAlertController(title: title, message: status.description, preferredStyle: .Alert)

        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func showAlert(title:String, error:NSError) {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .Alert)

        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
