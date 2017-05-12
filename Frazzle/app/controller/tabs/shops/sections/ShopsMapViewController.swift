//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class ShopsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet var map: MKMapView!
    private var timelineTitle:String!

    private var locationManager: CLLocationManager!

    private var shops:Array<User>!
    
    private var user:User!
    
    private var centerInLocationOnce:Bool! = false

    override func viewDidLoad() {

        super.viewDidLoad()

        loadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userLoggedIn(_:)), name: C.USERS_DOWNLOADED, object: nil)
        setupListeners()
    }

    func userLoggedIn(notification: NSNotification) {
        if (UserManager.isUserLoggedIn()) {
            loadData()
        } else {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if user != nil {
            let center = CLLocationCoordinate2D(latitude: (user.userLocation.latitude as NSString).doubleValue, longitude: (user.userLocation.longitude as NSString).doubleValue)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.map.setRegion(region, animated: true)
        }
    }
    private func loadData(){
        
        shops = UserManager.getUsersByType(C.UserType.SHOPS)
        if(shops.count>0){
            loadPins()
        }
        
        if user != nil {
            let center = CLLocationCoordinate2D(latitude: (user.userLocation.latitude as NSString).doubleValue, longitude: (user.userLocation.longitude as NSString).doubleValue)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
            self.map.setRegion(region, animated: true)
        }
    }

    private func loadPins(){
        var dropPin:MKPointAnnotation! = MKPointAnnotation()

        for shop:User in shops {
            dropPin = MKPointAnnotation()
            dropPin.coordinate = shop.getCLLocation().coordinate
            dropPin.title = shop.displayName
            map.addAnnotation(dropPin)
        }
    }

    private func setupListeners(){
        self.map.delegate = self

        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersDownloadedNotification(_:)), name:C.USERS_DOWNLOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopsViewController.onUsersNotDownloadedNotification(_:)), name:C.USERS_NOT_DOWNLOADED, object: nil)
    }

    @objc func onUsersDownloadedNotification(notification: NSNotification){
        shops = UserManager.getUsersByType(C.UserType.SHOPS)

        if(shops.count>0){
            loadPins()
        }

    }

    @objc func onUsersNotDownloadedNotification(notification: NSNotification){
        if(shops.count==0){
            //show toast
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }

        if (annotation.isKindOfClass(ShopAnnotation)) {
            let shopAnnotation = annotation as? ShopAnnotation
            mapView.translatesAutoresizingMaskIntoConstraints = false
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("ShopAnnotation") as MKAnnotationView!

            if (annotationView == nil) {
                annotationView = shopAnnotation?.annotationView()
            } else {
                annotationView.annotation = annotation;
            }

            let button = UIButton(type:UIButtonType.DetailDisclosure) as UIButton // button with info sign in it

            annotationView?.rightCalloutAccessoryView = button

            return annotationView
        } else {
            return nil
        }
    }

    func locationManager(UserManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last! as CLLocation

//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

//        if (!centerInLocationOnce) {
////            self.map.setRegion(region, animated: true)
//            centerInLocationOnce = true
//            locationManager.stopUpdatingLocation()
//        }
    }

    func setUser(user:User) {
        self.user = user
    }
}
