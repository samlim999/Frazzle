//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import Kingfisher
import Async

class UploadMenuViewController: UIKit.UIViewController {

    @IBOutlet var viewBackground: UIView!
    
    @IBOutlet var btnAddVideo: UIButton!
    @IBOutlet var btnNewLiveStream: UIButton!
    @IBOutlet var btnAddUpcoming: UIButton!

    @IBOutlet var btnClose: UIButton!

    var backgroundColor:UIColor?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let _ = backgroundColor {
            viewBackground.backgroundColor = backgroundColor!
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupListeners()
    }

    private func loadData(){

    }

    private func setupListeners(){
        btnAddVideo.addTarget(self, action: #selector(UploadMenuViewController.btnAddVideoClick(_:)), forControlEvents: .TouchUpInside)
        btnNewLiveStream.addTarget(self, action: #selector(UploadMenuViewController.btnNewLiveStreamClick(_:)), forControlEvents: .TouchUpInside)
        btnAddUpcoming.addTarget(self, action: #selector(UploadMenuViewController.btnAddUpcomingClick(_:)), forControlEvents: .TouchUpInside)

        btnClose.addTarget(self, action: #selector(UploadMenuViewController.btnCloseClick(_:)), forControlEvents: .TouchUpInside)

    }

    func btnAddVideoClick(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(C.OPEN_UPLOAD_VIDEO_VIEW, object: self)

        dismiss()
    }

    func btnNewLiveStreamClick(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(C.OPEN_LIVE_STREAMING_VIEW, object: self)

        dismiss()
    }


    func btnAddUpcomingClick(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(C.OPEN_UPCOMING_EVENT_VIEW, object: self)

        dismiss()
    }

    func btnCloseClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func dismiss(){
        Async.main(after: 0.1){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
