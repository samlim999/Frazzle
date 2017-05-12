//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import AVFoundation
import AVKit
import Async
import SwiftMessageBar

class MainViewController : UITabBarController {

    @IBOutlet var btnOpenLateralMenu: UIBarButtonItem!
    @IBOutlet var btnUpload: UIBarButtonItem!

    private var primaryColor: UIColor?

    private var openVideoPlayerFromNotification: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if (UserManager.isUserLoggedIn()) {
            self.navigationItem.rightBarButtonItem = self.btnUpload
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }

        let tabBar = self.tabBar

        let imgHome: UIImage! = UIImage(named: "tab-icon-home-unselected")?.imageWithRenderingMode(.AlwaysOriginal)
        let imgShops: UIImage! = UIImage(named: "tab-icon-shops-unselected")?.imageWithRenderingMode(.AlwaysOriginal)
        let imgPeople: UIImage! = UIImage(named: "tab-icon-profiles-unselected")?.imageWithRenderingMode(.AlwaysOriginal)
        let imgLive: UIImage! = UIImage(named: "tab-icon-live-broadcast-unselected")?.imageWithRenderingMode(.AlwaysOriginal)
        let imgSearch: UIImage! = UIImage(named: "tab-icon-search-unselected")?.imageWithRenderingMode(.AlwaysOriginal)

        (tabBar.items![0]).image = imgHome
        (tabBar.items![1]).image = imgShops
        (tabBar.items![2]).image = imgPeople
        (tabBar.items![3]).image = imgLive
        (tabBar.items![4]).image = imgSearch

        (tabBar.items![0]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        (tabBar.items![1]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        (tabBar.items![2]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        (tabBar.items![3]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        (tabBar.items![4]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)

        tabBar.tintColor = UIColor.whiteColor()

        primaryColor = ThemeUtil.getMainColor(C.TabType.HOME_TUNES)


        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.changeBarsAppereance(_:)), name: C.BOTTOM_TAB_CHANGED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.changeBarsAppereance(_:)), name: C.TOP_TAB_CHANGED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.userLoggedIn(_:)), name: C.USER_LOGGED_IN, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.userLoggedOut(_:)), name: C.USER_LOGGED_OUT, object: nil)


        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openUploadMedia(_:)), name: C.OPEN_UPLOAD_VIDEO_VIEW, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLiveStream(_:)), name: C.OPEN_LIVE_STREAMING_VIEW, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openUpcomingEvent(_:)), name: C.OPEN_UPCOMING_EVENT_VIEW, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.postDownloaded(_:)), name: C.NOTIFICATION_POST_DOWNLOADED, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.postNotDownloaded(_:)), name: C.NOTIFICATION_POST_NOT_DOWNLOADED, object: nil)

        // Define the menus
        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewControllerWithIdentifier("LeftMenuNavigationController") as? UISideMenuNavigationController

        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)

        // Set up a cool background image for demo purposes
        //SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)

        SideMenuManager.menuPresentMode = .MenuSlideIn
        SideMenuManager.menuFadeStatusBar = false


        let messageBarConfig = MessageBarConfig(successColor: ThemeUtil.getMainColor(C.TabType.HOME_HERBS), statusBarHidden: false)
        SwiftMessageBar.setSharedConfig(messageBarConfig)

        //Local test
        /*Async.background(after:5){
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

            appDelegate.prepareToShowRemoteNotification([String: AnyObject]())
        }*/
    }

    func postDownloaded(notification: NSNotification) {

        if (SimplePersistence.getBool("OPEN_VIDEO_FROM_NOTIFICATION")) {
            let post = PostsManager.getIndividualPost()

            if let _ = post {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let view = appDelegate.window?.rootViewController {
                    if let navigation = view as? UINavigationController {

                        let player = AVPlayer(URL: post!.getVideoUrl())
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player

                        navigation.presentViewController(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }


                        Async.background(after: 5.0) {
                            SimplePersistence.setBool("OPEN_VIDEO_FROM_NOTIFICATION", value: false)
                        }
                    }
                }
            }
        }
    }

    private func loadVideo(videoUrl: String) {
        let player = AVPlayer(URL: NSURL(string: videoUrl)!)
        let playerController = AVPlayerViewController()

        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame

        player.play()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userLoggedIn(notification: NSNotification) {
        if (UserManager.isUserLoggedIn()) {
            UserService.requestUsers()
            self.navigationItem.rightBarButtonItem = self.btnUpload
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    func userLoggedOut(notification: NSNotification) {
        if (UserManager.isUserLoggedIn()) {
            self.navigationItem.rightBarButtonItem = self.btnUpload
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    @IBAction func openLateralMenu(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(C.OPEN_LATERAL_MENU, object: self)
    }

    @IBAction func openAddDialog(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let upload = storyboard.instantiateViewControllerWithIdentifier("UploadMenuView") as! UploadMenuViewController
        upload.backgroundColor = primaryColor

        self.navigationController?.presentViewController(upload, animated: true, completion: nil)
        //self.navigationController?.pushViewController(upload, animated: true)
    }

    @objc func openUploadMedia(notification: NSNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let upload = storyboard.instantiateViewControllerWithIdentifier("UploadView") as! UploadViewController
        upload.backgroundColor = primaryColor

        self.navigationController?.pushViewController(upload, animated: false)
    }

    @objc func openLiveStream(notification: NSNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let broadcast = storyboard.instantiateViewControllerWithIdentifier("LiveBroadcastView") as! LiveBroadcastViewController
        //upload.backgroundColor = primaryColor

        self.navigationController?.pushViewController(broadcast, animated: false)
    }

    @objc func openUpcomingEvent(notification: NSNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let upcoming = storyboard.instantiateViewControllerWithIdentifier("NewUpcomingEventView") as! NewUpcomingEventViewController
        //upload.backgroundColor = primaryColor

        self.navigationController?.pushViewController(upcoming, animated: false)
    }

    @objc func changeBarsAppereance(notification: NSNotification) {
        let userInfo: Dictionary<String, String!> = notification.userInfo as! Dictionary<String, String!>
        if let type = userInfo["TabType"] {
            let tabType: C.TabType = C.TabType(rawValue: type)!

            primaryColor = ThemeUtil.getMainColor(tabType)

            self.tabBar.barTintColor = ThemeUtil.getMainColor(tabType)
            self.tabBar.tintColor = ThemeUtil.getWhiteColor()

            self.navigationController?.navigationBar.barTintColor = ThemeUtil.getMainColor(tabType)
            self.navigationController?.navigationBar.tintColor = ThemeUtil.getWhiteColor()


            self.navigationItem.title = ThemeUtil.getTabTitle(tabType)


            let messageBarConfig = MessageBarConfig(successColor: ThemeUtil.getMainColor(tabType), statusBarHidden: false, successIcon: UIImage(named: "icon-new-live-streaming"))

            SwiftMessageBar.setSharedConfig(messageBarConfig)

            /*if(tabType == C.TabType.SEARCH){
                self.navigationController?.navigationBar.hidden = true
            }else{
                self.navigationController?.navigationBar.hidden = false
            }*/
        }
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}