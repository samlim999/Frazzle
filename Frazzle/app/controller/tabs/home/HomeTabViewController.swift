//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation

import UIKit
import CarbonKit
import SideMenu
import Toast_Swift
import UIColor_Hex_Swift

class HomeTabViewController: UIViewController,CarbonTabSwipeNavigationDelegate {

    @IBOutlet var btnSideMenu: UIButton!
    @IBOutlet var viewContent: UIView!

    private var carbonTabSwipeNavigation:CarbonTabSwipeNavigation!

    private let tabTitles = [C.TOP_TAB_NAME_HOME_HERBS, C.TOP_TAB_NAME_HOME_TUNES, C.TOP_TAB_NAME_HOME_VIBES]
    private let tabContentTypes = [C.TimelineType.HERBS,C.TimelineType.TUNES,C.TimelineType.VIBES]
    private let tabTypes = [C.TabType.HOME_HERBS, C.TabType.HOME_TUNES, C.TabType.HOME_VIBES]

    private var tabType:C.TabType!
    private var visible:Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupListeners()

        TimelineManager.fetchTimelineFromServer();
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view:TimelineViewController = storyboard.instantiateViewControllerWithIdentifier("TimeLineView") as! TimelineViewController

        view.setType(self.tabContentTypes[Int(index)])

        return view
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAtIndex index: UInt) {
        carbonTabSwipeNavigation.setIndicatorColor(ThemeUtil.getAccentColor(self.tabTypes[Int(index)]))
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        tabType = C.TabType.HOME_HERBS

        NSNotificationCenter.defaultCenter().postNotificationName(C.BOTTOM_TAB_CHANGED, object: self, userInfo:["TabType":C.TabType.HOME_HERBS.rawValue])

        visible = true
    }

    override func viewDidDisappear(animated: Bool){
        visible = false
    }


    @objc func changeBarsAppereance(notification: NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        if let type = userInfo["TabType"] {
            tabType = C.TabType(rawValue:type)!
        }
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeTabViewController.openCloseSideMenu(_:)), name:C.OPEN_LATERAL_MENU, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.changeBarsAppereance(_:)), name:C.TOP_TAB_CHANGED, object: nil)
    }

    func openCloseSideMenu(notification: NSNotification){
        if (visible){
            presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        }
    }
}
