//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ShopAnnotation : NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var detailURL: NSURL

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, detailURL: NSURL) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.detailURL = detailURL
    }

    func annotationView() -> MKAnnotationView {
        let view = MKAnnotationView(annotation: self, reuseIdentifier: "ShopAnnotation")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.enabled = true
        view.canShowCallout = true
        view.image = UIImage(named: "location-4")
        view.rightCalloutAccessoryView = UIButton(type: UIButtonType.Custom)
        view.centerOffset = CGPointMake(0, -32)
        return view
    }
}
