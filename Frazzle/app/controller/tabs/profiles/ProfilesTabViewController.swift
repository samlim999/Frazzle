//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import CarbonKit
import SideMenu
import Toast_Swift
import UIColor_Hex_Swift
import AlamofireImage
import Alamofire


class ProfilesTabViewController: UIViewController, CarbonTabSwipeNavigationDelegate  {

    @IBOutlet var btnSideMenu: UIButton!

    @IBOutlet var viewContent: UIView!

    private var carbonTabSwipeNavigation:CarbonTabSwipeNavigation!

    private let tabTitles = [C.TOP_TAB_NAME_PEOPLE_PEOPLE, C.TOP_TAB_NAME_PEOPLE_FOLLOWING, C.TOP_TAB_NAME_PEOPLE_FOLLOWERS]
    private let tabContentTypes = [C.UsersType.PROFILES, C.UsersType.FOLLOWING,C.UsersType.FOLLOWERS]
    private let tabTypes = [C.TabType.USERS_PROFILES, C.TabType.USERS_PROFILES, C.TabType.USERS_PROFILES]

    private var visible:Bool = false


    override func viewDidLoad() {
        setupTabBar()

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userLoggedIn(_:)), name: C.USERS_DOWNLOADED, object: nil)

        //setupSideMenu()
        setupListeners()

        UserManager.fetchUsersFromServer()
        UserManager.fetchFollowers()
        UserManager.fetchFollowing()
    }

    func userLoggedIn(notification: NSNotification) {
        if (UserManager.isUserLoggedIn()) {
//            UserManager.fetchUsersFromServer()
            UserManager.fetchFollowers()
            UserManager.fetchFollowing()
        } else {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let type:C.TabType = C.TabType.USERS_PROFILES

        NSNotificationCenter.defaultCenter().postNotificationName(C.BOTTOM_TAB_CHANGED, object: self, userInfo:["TabType":type.rawValue])
        visible = true
    }

    override func viewDidDisappear(animated: Bool){
        visible = false
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view:PeopleViewController = storyboard.instantiateViewControllerWithIdentifier("PeopleView") as! PeopleViewController

        view.setType(self.tabContentTypes[Int(index)])

        return view
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAtIndex index: UInt) {
        carbonTabSwipeNavigation.setIndicatorColor(ThemeUtil.getAccentColor(self.tabTypes[Int(index)]))
    }


    private func setupSideMenu() {
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

    }

    private func setupTabBar(){

        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: tabTitles, delegate: self)

        let width = UIScreen.mainScreen().bounds.width / CGFloat(tabTitles.count)

        for index in 0 ... tabTitles.count-1{
            carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(width,forSegmentAtIndex:index)
        }

        carbonTabSwipeNavigation.setTabBarHeight(navigationController!.navigationBar.frame.size.height)
        carbonTabSwipeNavigation.setIndicatorHeight(C.TOP_TAB_INDICATOR_HEIGHT)
        carbonTabSwipeNavigation.carbonTabSwipeScrollView.backgroundColor = UIColor.whiteColor()
        carbonTabSwipeNavigation.setNormalColor(ThemeUtil.getTopTabFontColor());
        carbonTabSwipeNavigation.setSelectedColor(ThemeUtil.getTopTabFontColor());

        carbonTabSwipeNavigation.insertIntoRootViewController(self, andTargetView: viewContent)

    }

    private func setupListeners() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfilesTabViewController.openCloseSideMenu(_:)), name:C.OPEN_LATERAL_MENU, object: nil)
    }

    func openCloseSideMenu(notification: NSNotification){
        if (visible) {
            presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
