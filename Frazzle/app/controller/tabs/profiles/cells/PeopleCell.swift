//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Alamofire
import AlamofireImage
import Toast_Swift


class PeopleCell: UITableViewCell {
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var btnFollow: UIButton!
    
    private var user:User!
    private var followingusers:Array<User>!

    private var alreadyFollowingUser:Bool = false
    private var followingUserTab:Bool = false

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUser(user:User){
        self.user=user

        setupInfo()
        setupListeners()
    }

    private func setupListeners(){
        btnFollow.addTarget(self, action: #selector(PeopleCell.btnFollowClick(_:)), forControlEvents: .TouchUpInside)
    }

    func btnFollowClick(sender:UIButton) {
        if (!alreadyFollowingUser) {
            UserManager.followUser(user)
            UserManager.addUserToFollowing(user)
        } else {
            UserManager.unFollowUser(user)
            UserManager.removeUserFromFollowing(user)
        }

        self.alreadyFollowingUser = !self.alreadyFollowingUser
        self.setAlreadyFollowingUser(self.alreadyFollowingUser)

        if (!followingUserTab) {
            NSNotificationCenter.defaultCenter().postNotificationName(C.FOLLOWING_DOWNLOADED, object: self)
        }
    }

    private func setupInfo(){
        self.lblName.text = user.displayName
        self.lblDescription.text = user.description

        let filter = CircleFilter()

        let imageUrl: NSURL = NSURL(string:user.picUrl)!

        Request.addAcceptableImageContentTypes(["binary/octet-stream"])

        imgProfile.af_setImageWithURL(
                imageUrl,
                placeholderImage: nil,
                filter: filter,
                imageTransition: .CrossDissolve(0.2)
                )



        /*imgProfile.af_setImageWithURL(imageUrl, placeholderImage: nil, filter: nil, imageTransition: .None, completion: { (response) -> Void in
            print("image: \(self.imgProfile.image)")
            print(response.result.value) //# UIImage
            print(response.result.error) //# NSError

        })*/

        //imgProfile.af_setImageWithURL(imageUrl)
    }

    func setFollowingTab(followingTab:Bool){
        self.alreadyFollowingUser = followingTab
    }


    func setAlreadyFollowingUser(following:Bool){

        self.alreadyFollowingUser = following
        
        if(following){
            btnFollow.setImage(UIImage(named: "btn-unfollow-user") as UIImage!, forState: .Normal)
        }else{
            btnFollow.setImage(UIImage(named: "btn-follow-user") as UIImage!, forState: .Normal)
        }
        
    }

    func hideFollowButton(){
        btnFollow.hidden = true
    }
}
