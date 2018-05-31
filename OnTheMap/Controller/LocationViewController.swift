//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {
    
    @IBOutlet weak var textLocation: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaURLTextField.delegate = TextFieldDelegate.sharedInstance
        textLocation.delegate = TextFieldDelegate.sharedInstance
    }
    
    @IBAction func performCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func performFindOnMap(_ sender: Any) {
        if (textLocation.text! == "") {
            let alert = UIAlertController(title: "Alert", message: "Please enter a location.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "URLViewController") as! URLViewController
        vc.location = textLocation.text!
        vc.mediaURLTextField = mediaURLTextField.text!
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

