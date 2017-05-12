//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation

import UIKit
import CarbonKit
import SideMenu
import Toast_Swift
import UIColor_Hex_Swift

class SearchTabViewController: UIViewController,CarbonTabSwipeNavigationDelegate, UISearchBarDelegate{

    @IBOutlet var btnSideMenu: UIButton!
    
    @IBOutlet var searchBar: UISearchBar!

    @IBOutlet var viewContent: UIView!

    private var carbonTabSwipeNavigation:CarbonTabSwipeNavigation!

    private let tabTitles = [C.TOP_TAB_NAME_SEARCH_TOP, C.TOP_TAB_NAME_SEARCH_SHOPS, C.TOP_TAB_NAME_SEARCH_PEOPLE]
    private let tabTypes = [C.TabType.SEARCH, C.TabType.SEARCH, C.TabType.SEARCH]

    private var visible:Bool = false


    var posts:TimelineViewController!
    var people:PeopleViewController!
    var shops:ShopsViewController!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {


        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        UserManager.setSearchQuery("")
        //setupSideMenu()
        setupListeners()

        setupTabBar()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let type:C.TabType = C.TabType.SEARCH

        NSNotificationCenter.defaultCenter().postNotificationName(C.BOTTOM_TAB_CHANGED, object: self, userInfo:["TabType":type.rawValue])
        visible = true
    }

    override func viewDidDisappear(animated: Bool){
        visible = false
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let _ = posts {
        }else{
            posts = storyboard.instantiateViewControllerWithIdentifier("TimeLineView") as! TimelineViewController
            posts.setAsSearchView()
            posts.setType(C.TimelineType.SEARCH)
        }

        if let _ = shops {
        }else{
            shops = storyboard.instantiateViewControllerWithIdentifier("ShopsView") as! ShopsViewController
            shops.setAsSearchView()
        }


        if let _ = people {
        }else{
            people = storyboard.instantiateViewControllerWithIdentifier("PeopleView") as! PeopleViewController
            people.setType(C.UsersType.SEARCH)
            people.setAsSearchView()
        }

        switch index{
        case 0: return posts
        case 1: return shops
        default: return people
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

        for index in 0 ... tabTitles.count-1 {
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
        searchBar.showsCancelButton = true
        searchBar.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchTabViewController.openCloseSideMenu(_:)), name: C.OPEN_LATERAL_MENU, object: nil)

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

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //shouldShowSearchResults = true
        //tblSearchResults.reloadData()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //shouldShowSearchResults = false
        //tblSearchResults.reloadData()

        searchBar.resignFirstResponder()

        posts!.setBlankState()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        UserManager.setSearchQuery(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        searchBar.resignFirstResponder()

        if let query:String = searchBar.text {
            if(query.trim() != ""){
                posts!.setLoadingState()
                people!.setLoadingState()
                shops!.setLoadingState()

                SearchManager.search(query)
            }
        }
    }
}
