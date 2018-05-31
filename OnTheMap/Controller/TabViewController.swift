//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class TabViewController: UITabBarController {
    
    @IBAction func performLogout(_ sender: Any) {
        UdacityClient.sharedInstance().performUdacityLogout(completionHandlerLogout: { (error) in
            self.updateUIAfterLogout(error: error)
        })
    }
    
    @IBAction func performRefresh(_ sender: Any) {
        if (selectedIndex == 0) {
            let vc = selectedViewController as! MapViewController
            vc.getStudentsInformation()
        }
        else {
            let vc = selectedViewController as! TableViewController
            vc.getStudentsInformation()
        }
    }
    
    @IBAction func performAddStudent(_ sender: Any) {
        let studentInformations = ParseClient.sharedInstance().studentsInformation!
        addStudentInformation(studentInformations)
    }
    
    private func updateUIAfterLogout(error: NSError?) {
        DispatchQueue.main.async {
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addStudentInformation(_ studentInformations: [StudentInformation]) {
        var doesExist: Bool = false
        let currentUserUniqueKey = UdacityClient.sharedInstance().AccountKey
        var currentStudent: StudentInformation?
        
        for studentInformation in studentInformations {
            if (studentInformation.UniqueKey == currentUserUniqueKey) {
                currentStudent = studentInformation
                doesExist = true
                break
            }
        }
        
        // Create an alert for overwriting student's location if a pin was allready dropped
        if (doesExist) {
            let alert = UIAlertController(title: "Warning", message: "User \(currentStudent!.FirstName) \(currentStudent!.LastName) has already posted a student location. Would you like to overwrite their location?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: {_ in
                self.presentUpdateStudentInfoView()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            presentUpdateStudentInfoView()
        }
    }
    
    private func presentUpdateStudentInfoView() {
        let updateLocationVC = self.storyboard!.instantiateViewController(withIdentifier: "UpdateNavigationController")
        self.present(updateLocationVC, animated: true, completion: nil)
    }
}
