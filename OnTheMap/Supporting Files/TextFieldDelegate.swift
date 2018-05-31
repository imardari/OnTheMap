//
//  TextFieldDelegate.swift
//  OnTheMap
//
//  Created by Ion M on 5/29/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit

class TextFieldDelegate : NSObject, UITextFieldDelegate {
    
    static let sharedInstance : TextFieldDelegate = TextFieldDelegate()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
