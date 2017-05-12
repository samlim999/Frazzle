//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage


class ProfileViewController: UIViewController  {

    @IBOutlet var imgCover: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblFollowers: UILabel!
    @IBOutlet var lblFollowing: UILabel!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblOpenHours: UILabel!
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var collectionPosts: UICollectionView!

    private var user:User!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userLoggedIn(_:)), name: C.USERS_DOWNLOADED, object: nil)
        
        loadData()
        setupListeners()

    }

    private func loadData(){

        if let _ = self.user {

            lblUsername.text = user.username
            lblDescription.text = user.description
            lblFollowers.text = String(user.followerCount)
            lblFollowing.text = String(user.followingCount)
            lblAddress.text = user.getAddress()

            if let _ = user.shopInfo {
                lblOpenHours.text = user.shopInfo!.getOpenHours()
            }else{
                lblOpenHours.hidden = true
            }

            Request.addAcceptableImageContentTypes(["binary/octet-stream"])

            var imageUrl: NSURL = NSURL(string:user.picUrl)!

            let filter = CircleFilter()
            imgProfile.af_setImageWithURL(
                    imageUrl,
                    placeholderImage: nil,
                    filter: filter,
                    imageTransition: .CrossDissolve(0.2)
                    )

            imageUrl = NSURL(string:user.coverPicUrl)!
            imgCover.af_setImageWithURL(imageUrl)

            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.AddressTapped(_:)))
            lblAddress.userInteractionEnabled = true
            lblAddress.addGestureRecognizer(tapGestureRecognizer)

        }
    }

    func userLoggedIn(notification: NSNotification) {
        if (UserManager.isUserLoggedIn()) {
            loadData()
        } else {
            
        }
    }
    
    func AddressTapped(img: AnyObject)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profile = storyboard.instantiateViewControllerWithIdentifier("ShopsMapView") as! ShopsMapViewController
        
        profile.setUser(user)
        
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    private func setupListeners(){
        //btnSideMenu.addTarget(self, action: Selector("openCloseSideMenu:"), forControlEvents: .TouchUpInside)
    }

    func setUser(user:User) {
        self.user = user
    }
}
