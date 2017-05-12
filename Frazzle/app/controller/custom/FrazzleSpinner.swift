//
//  Copyright © 2016 Frazzle. All rights reserved.
//

import UIKit

var Conten:UIView!

class FrazzleSpinner: NSObject {
    
    
    func rotateView(targetView: UIView, duration: Double = 1.0) {
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveLinear, animations: {
            targetView.transform = CGAffineTransformRotate(targetView.transform, CGFloat(M_PI))
        }) { finished in
            self.rotateView(targetView, duration: duration)
        }
    }
    
    func StartLoading(targetView: UIView){
        print(targetView.viewWithTag(100))
        
        if targetView.viewWithTag(100) == nil {
            let imageName = "iconloading"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            
            
            imageView.frame = CGRect(x: (targetView.frame.width/2)+20, y: (targetView.frame.height/2)-10, width: 30, height: 70)
            targetView.addSubview(imageView)
            
            targetView.tag = 100
            
            
            rotateView(imageView)
            
        }
        else{
            
            targetView.viewWithTag(100)?.hidden = false
            
        }
        
    }
    
    func StopLoading(targetView: UIView){
        
        
        targetView.viewWithTag(100)!.hidden = true
        
        
    }
    
    
}
