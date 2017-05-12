//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CarbonKit

class ShopsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet var viewLoading: UIView!
    @IBOutlet var lblLoading: UILabel!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var shopList: UITableView!

    private var carbonRefresh:CarbonSwipeRefresh!
    
    public var carbonTabSwipeNavigation:CarbonTabSwipeNavigation!
    
    private var locationManager: CLLocationManager!
    private var currentUserLocation: CLLocation?

    private var shops:Array<User>!

    private var centerInLocationOnce:Bool! = false

    private var timelineTitle:String!

    private var isSearchView:Bool=false
    private var isViewLoaded:Bool=false

    var locationStatus : NSString = "Not Started"
    
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
            shopList.hidden = true

            carbonRefresh.endRefreshing()
        }
    }

    func setBlankState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            shopList.hidden = true

            carbonRefresh.endRefreshing()
        }
    }

    func setWithContentState(){
        if (isViewLoaded) {
            viewLoading.hidden = true
            shopList.hidden = false

            carbonRefresh.endRefreshing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

            carbonRefresh = CarbonSwipeRefresh(scrollView: shopList)
            carbonRefresh.colors = [ThemeUtil.getMainColor(C.TabType.SHOPS)]
            self.view.addSubview(carbonRefresh)

            if(!isSearchView){
            carbonRefresh.addTarget(self, action: #selector(TimelineViewController.refreshContent(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }

        isViewLoaded = true

        if (!isSearchView) {
            loadData()
        }else{
            setBlankState()

            let query = UserManager.getSearchQuery() as String
            if query.isEmpty || query.characters.count == 0 {
                
            } else {
                print ("query :", UserManager.getSearchQuery())
                SearchManager.search(UserManager.getSearchQuery())
            }
            
            shops = Array<User>()

            shopList.dataSource = self
            shopList.delegate = self
        }
        setupListeners()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userLoggedIn(_:)), name: C.USERS_DOWNLOADED, object: nil)
    }

    func userLoggedIn(notification: NSNotification) {
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

        shops = UserManager.getUsersByType(C.UserType.SHOPS)
        if(shops.count>0){
            setWithContentState()
        }else{
            setLoadingState()
        }

        shopList.dataSource = self
        shopList.delegate = self

        shopList.reloadData()
    }

    private func setupListeners(){
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }

        if(isSearchView) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name: C.SEARCH_SHOPS_DOWNLOADED, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name: C.SEARCH_SHOPS_NOT_DOWNLOADED, object: nil)
        }else{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name: C.SHOPS_DOWNLOADED, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name: C.SHOPS_NOT_DOWNLOADED, object: nil)
        }
    }

    func refreshContent(sender: AnyObject){
        UserManager.fetchShops()

        setLoadingState()
    }

    @objc func onUsersDownloadedNotification(notification: NSNotification){
        if(!isSearchView) {
            shops = UserManager.getUsersByType(C.UserType.SHOPS)
        }else{
            shops = UserManager.getShopsSearchResults()
//            var allshops:Array<User>!
//            allshops = UserManager.getUsersByType(C.UserType.SHOPS)
//            
//            for shop in allshops {
//                if shop.username.containsString()
//            }
        }
        
        
//        shops = UserManager.getUsersByType(C.UserType.SHOPS)

        shopList.reloadData()

        if(shops.count==0){
            setEmptyState()
        }else{
            setWithContentState()
        }

    }

    @objc func onUsersNotDownloadedNotification(notification: NSNotification){
        if(shops.count==0){
            setEmptyState()
        }else{
            setWithContentState()
        }
    }

    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopCell", forIndexPath: indexPath)

        if let cell = cell as? ShopCell {

            let shop:User = shops[indexPath.row] as User

            if let _ = currentUserLocation {
                cell.setCurrentUserLocation(currentUserLocation!)
            }
            
            cell.setShop(shop)
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user:User = shops[indexPath.row] as User
        
        print ("location : ", user.userLocation.toJson())
        
        
        
        openProfile(user)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.last! as CLLocation

        print ("latitude = %f", currentUserLocation?.coordinate.latitude);
        print ("longtitude = %f", currentUserLocation?.coordinate.longitude);
        
        if (!centerInLocationOnce) {
            centerInLocationOnce = true
            locationManager.stopUpdatingLocation()

            shopList.reloadData()
        }
    }

    // authorization status
    func locationManager(manager: CLLocationManager!,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
    
    func openProfile(user:User){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profile = storyboard.instantiateViewControllerWithIdentifier("ProfileView") as! ProfileViewController
        
        profile.setUser(user)

        self.navigationController?.pushViewController(profile, animated: true)
//        let viewcontrollers = carbonTabSwipeNavigation.viewControllers
////        
////        let mapView : ShopsMapViewController!
////        mapView = (ShopsMapViewController) viewcontrollers[1]
//        
//        let keys = viewcontrollers.allKeys
//        let values = viewcontrollers.allValues
//        
//        print (keys)
//        print(values)
        
//        UserManager.setShopUser(user)
//        
//        carbonTabSwipeNavigation.setCurrentTabIndex(1, withAnimation: true)
        

    }

}
