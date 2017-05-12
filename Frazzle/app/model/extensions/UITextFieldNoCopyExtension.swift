//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation

import UIKit

var key: Void?

class UITextFieldAdditions: NSObject {
    var readonly: Bool = false
}

extension UITextField {
    var readonly: Bool {
        get {
            return self.getAdditions().readonly
        }
        set {
            self.getAdditions().readonly = newValue
        }
    }

    private func getAdditions() -> UITextFieldAdditions {
        var additions = objc_getAssociatedObject(self, &key) as? UITextFieldAdditions
        if additions == nil {
            additions = UITextFieldAdditions()
            objc_setAssociatedObject(self, &key, additions!, objc_AssociationPolicy(rawValue: 1)!)//OBJC_ASSOCIATION_RETAIN_NONATOMIC
        }
        return additions!
    }

    public override func targetForAction(action: Selector, withSender sender: AnyObject?) -> AnyObject? {
        if ((action == Selector("paste:") || (action == Selector("cut:"))) && self.readonly) {
            return nil
        }
        return super.targetForAction(action, withSender: sender)
    }

}