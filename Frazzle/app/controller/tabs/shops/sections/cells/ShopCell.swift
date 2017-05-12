//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import AlamofireImage
import Toast_Swift
import CoreLocation


class ShopCell: UITableViewCell {
    

    @IBOutlet var lblShopname: UILabel!
    @IBOutlet var textAddress: UITextView!
    @IBOutlet var lblDistance: UILabel!
    private var shop:User!

    private var currentUserLocation: CLLocation?

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setShop(shop:User){
        self.shop=shop

        setupInfo()
    }

    func setCurrentUserLocation(currentUserLocation: CLLocation){
        self.currentUserLocation = currentUserLocation
    }
    
    func setupInfo(){
        self.lblShopname.text = shop.displayName
        self.textAddress.text = shop.getAddress()

        if let _ = currentUserLocation {
            self.lblDistance.text = shop.getDistanceUsingCurrentUserLocation(currentUserLocation!)
        }
    }
}
