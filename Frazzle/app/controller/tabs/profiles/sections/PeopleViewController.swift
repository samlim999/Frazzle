//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import CarbonKit

class PeopleViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var viewLoading: UIView!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblLoading: UILabel!
    
    @IBOutlet var peopleList: UITableView!

    private var carbonRefresh:CarbonSwipeRefresh!

    private var usersType:C.UsersType!
    
    private var manager:UserManager!
    private var users:Array<User>!
    
    private var usersDict:Dictionary<String,User>!

    private var timelineTitle:String!

    private var isLoggedIn:Bool=false
    private var isSearchView:Bool=false
    private var isViewLoaded:Bool=false

    func setAsSearchView(){
        self.isSearchView = true
    }

    func setLoadingState(){
        if (isViewLoaded) {
            viewLoading.hidden = false
            indicatorLoading.hidden = true
            lblLoading.hidden = true
            lblLoading.text = "Loading..."

            carbonRefresh.startRefreshing()

        }
    }

    func setEmptyState(){
        if (isViewLoaded) {
            viewLoading.hidden = false
            indicatorLoading.hidden = true
            lblLoading.hidden = false
            lblLoading.text = "No items to display"
            peopleList.hidden = true

            carbonRefresh.endRefreshing()
        }
    }

    func setBlankState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            peopleList.hidden = true

            carbonRefresh.endRefreshing()
        }
    }

    func setWithContentState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            peopleList.hidden = false

            carbonRefresh.endRefreshing()
        }
    }

    func setType(type:C.UsersType){
        self.usersType = type

        self.isSearchView = false

        switch type {
            case C.UsersType.PROFILES:
                timelineTitle = C.TOP_TAB_NAME_PEOPLE_PEOPLE
            case C.UsersType.FOLLOWERS:
                timelineTitle = C.TOP_TAB_NAME_PEOPLE_FOLLOWERS
            case C.UsersType.FOLLOWING:
                timelineTitle = C.TOP_TAB_NAME_PEOPLE_FOLLOWING
            case C.UsersType.SEARCH:
                timelineTitle = C.TOP_TAB_NAME_PEOPLE_PEOPLE
                self.isSearchView = true
        }
    }

    
    override func viewDidLoad() {

        super.viewDidLoad()

            carbonRefresh = CarbonSwipeRefresh(scrollView: peopleList)
            carbonRefresh.colors = [ThemeUtil.getMainColor(C.TabType.SHOPS)]
            self.view.addSubview(carbonRefresh)

        if(!isSearchView){
            carbonRefresh.addTarget(self, action: #selector(TimelineViewController.refreshContent(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userLoggedIn(_:)), name: C.USERS_DOWNLOADED, object: nil)

        isViewLoaded = true
        isLoggedIn = UserManager.isUserLoggedIn()

        if (!isSearchView) {
            loadData()
        }else{
            setBlankState()

//            users = Array<User>()
            let query = UserManager.getSearchQuery() as String
            if query.isEmpty || query.characters.count == 0 {
                
            } else {
                print ("query :", UserManager.getSearchQuery())
                SearchManager.search(UserManager.getSearchQuery())
            }

            users = UserManager.getUsersByType(C.UserType.USERS)
            
            usersDict = UserManager.getFollowingAsDict()

            peopleList.dataSource = self
            peopleList.delegate = self
        }
        setupListeners()
    }

    func userLoggedIn(notification: NSNotification) {
        isLoggedIn = UserManager.isUserLoggedIn()
//        usersDict = UserManager.getFollowingAsDict()
        UserManager.fetchFollowers()
        UserManager.fetchFollowing()

        if (UserManager.isUserLoggedIn()) {
            if (!isSearchView) {
                loadData()
            }
        } else {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        isViewLoaded = true
    }

    private func loadData(){
        
        usersDict = UserManager.getFollowingAsDict()
        
        switch self.usersType! {
        case C.UsersType.PROFILES:
            users = UserManager.getUsersByType(C.UserType.USERS)
        case C.UsersType.FOLLOWERS:
            if(UserManager.isUserLoggedIn()) {
                users = UserManager.getFollowers()
            }
        case C.UsersType.FOLLOWING:
            if(UserManager.isUserLoggedIn()) {
                users = UserManager.getFollowing()
            }
        case C.UsersType.SEARCH:
            users = UserManager.getUsersByType(C.UserType.USERS)
        }

        if let _ = users {

        }else{
            users = Array<User>()
        }

        if(users.count>0){
            setWithContentState()
        }else{
            setEmptyState()
//            if(UserManager.isUserLoggedIn()) {
//                setLoadingState()
//            }else{
//                setEmptyState()
//            }
        }

        peopleList.dataSource = self
        peopleList.delegate = self

        peopleList.reloadData()
    }

    private func setupListeners(){
        if(isSearchView) {
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name: C.SEARCH_USERS_DOWNLOADED, object: nil)
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name: C.SEARCH_USERS_NOT_DOWNLOADED, object: nil)

            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersDownloadedNotification(_:)), name: C.SEARCH_USERS_DOWNLOADED, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersNotDownloadedNotification(_:)), name: C.SEARCH_USERS_NOT_DOWNLOADED, object: nil)

        }else{
            switch self.usersType! {
//            case C.UsersType.PROFILES:
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name: C.USERS_DOWNLOADED, object: nil)
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name: C.USERS_NOT_DOWNLOADED, object: nil)
//            case C.UsersType.FOLLOWERS:
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name: C.FOLLOWERS_DOWNLOADED, object: nil)
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name: C.FOLLOWERS_NOT_DOWNLOADED, object: nil)
//            case C.UsersType.FOLLOWING:
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name: C.FOLLOWING_DOWNLOADED, object: nil)
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name: C.FOLLOWING_NOT_DOWNLOADED, object: nil)
//            case C.UsersType.SEARCH:()

            case C.UsersType.PROFILES:
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersDownloadedNotification(_:)), name: C.USERS_DOWNLOADED, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersNotDownloadedNotification(_:)), name: C.USERS_NOT_DOWNLOADED, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersDownloadedNotification(_:)), name: C.FOLLOWING_DOWNLOADED, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersNotDownloadedNotification(_:)), name: C.FOLLOWING_NOT_DOWNLOADED, object: nil)
            case C.UsersType.FOLLOWERS:
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersDownloadedNotification(_:)), name: C.FOLLOWERS_DOWNLOADED, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersNotDownloadedNotification(_:)), name: C.FOLLOWERS_NOT_DOWNLOADED, object: nil)
            case C.UsersType.FOLLOWING:
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersDownloadedNotification(_:)), name: C.FOLLOWING_DOWNLOADED, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUsersNotDownloadedNotification(_:)), name: C.FOLLOWING_NOT_DOWNLOADED, object: nil)
            case C.UsersType.SEARCH:()

            }

        }
    }

    func refreshContent(sender: AnyObject){
        UserManager.fetchUsersFromServer()

        setLoadingState()
    }

    @objc func onUsersDownloadedNotification(notification: NSNotification){
        if(!isSearchView) {
            switch self.usersType! {
            case C.UsersType.PROFILES:
                users = UserManager.getUsersByType(C.UserType.USERS)
            case C.UsersType.FOLLOWERS:
                users = UserManager.getFollowers()
            case C.UsersType.FOLLOWING:
                users = UserManager.getFollowing()
            case C.UsersType.SEARCH:
                users = UserManager.getUsersFromSearch()
            }
            
            if(users.count==0){
                setEmptyState()
            }else{
                setWithContentState()
            }
        }else{
            users = UserManager.getUsersFromSearch()

            if(users.count==0){
                setEmptyState()
            }else{
                setWithContentState()
            }
        }

        peopleList.reloadData()
    }

    @objc func onUsersNotDownloadedNotification(notification: NSNotification){
        if(users.count>0){
            setWithContentState()
        }else{
            if(UserManager.isUserLoggedIn()) {
                setEmptyState()
            }else{
                setEmptyState()
            }
        }
    }

    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath: indexPath)

        if let cell = cell as? PeopleCell {

            let user:User = users[indexPath.row] as User

            cell.setUser(user)
            if(isLoggedIn) {
                cell.setAlreadyFollowingUser(usersDict[user.username] != nil)
            }else{
                cell.hideFollowButton()
            }

            cell.setFollowingTab(self.usersType == C.UsersType.FOLLOWING)

        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user:User = users[indexPath.row] as User
        peopleList.deselectRowAtIndexPath(indexPath, animated: true)
        openProfile(user)
    }


    func openProfile(user:User){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let profile = storyboard.instantiateViewControllerWithIdentifier("ProfileView") as! ProfileViewController

        profile.setUser(user)

        self.navigationController?.pushViewController(profile, animated: true)

    }
}
