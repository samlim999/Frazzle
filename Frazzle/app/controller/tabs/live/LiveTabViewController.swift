//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation

import UIKit
import CarbonKit
import SideMenu
import Toast_Swift
import UIColor_Hex_Swift


class LiveTabViewController: UIViewController, CarbonTabSwipeNavigationDelegate  {

    @IBOutlet var btnSideMenu: UIButton!

    @IBOutlet var viewContent: UIView!

    private var carbonTabSwipeNavigation:CarbonTabSwipeNavigation!

    private let tabTitles = [C.TOP_TAB_NAME_LIVE_STREAMS_LIVE, C.TOP_TAB_NAME_LIVE_STREAMS_UPCOMING]
    private let tabContentTypes = [C.UsersType.PROFILES, C.UsersType.FOLLOWING]
    private let tabTypes = [C.TabType.LIVE, C.TabType.LIVE]
    
    let type:C.TabType = C.TabType.LIVE
    private var visible:Bool = false


    override func viewDidLoad() {
        setupTabBar()

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //setupSideMenu()
        setupListeners()

        TimelineManager.fetchTimelineFromServer();
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().postNotificationName(C.BOTTOM_TAB_CHANGED, object: self, userInfo:["TabType":type.rawValue])
        visible = true
    }

    override func viewDidDisappear(animated: Bool){
        visible = false
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch index{
        case 0:
            let view:TimelineViewController = storyboard.instantiateViewControllerWithIdentifier("TimeLineView") as! TimelineViewController
            view.setType(C.TimelineType.LIVE)
            return view
        default:
            let view:UpcomingViewController = storyboard.instantiateViewControllerWithIdentifier("UpcomingView") as! UpcomingViewController
            return view
        }
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveTabViewController.openCloseSideMenu(_:)), name:C.OPEN_LATERAL_MENU, object: nil)
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
