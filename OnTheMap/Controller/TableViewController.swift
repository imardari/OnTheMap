//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentsInformation()
    }
    
    func getStudentsInformation() {
        let parameters = [
            ParseClient.MultipleStudentParameterKeys.Limit: "100",
            ParseClient.MultipleStudentParameterKeys.Order: "-updatedAt"
        ]
        
        ParseClient.sharedInstance().getStudentsLocations(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentsInformation, error) in
            if let studentsInformation = studentsInformation {
                SharedData.sharedInstance.studentsInformation = studentsInformation
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.performAlert("There was an error retrieving student data")
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentInformation = SharedData.sharedInstance.studentsInformation[(indexPath as NSIndexPath).row]
        if (studentInformation.MediaURL != "") {
            UIApplication.shared.open(URL(string: studentInformation.MediaURL)!, options: [:], completionHandler: { (isSuccess) in
                if (isSuccess == false) {
                    self.performAlert("The URL is not valid. Please provide a valid URL.")
                }
            })
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "URL is not valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedData.sharedInstance.studentsInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentInformation = SharedData.sharedInstance.studentsInformation[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = studentInformation.FirstName + " " + studentInformation.LastName
        cell.detailTextLabel!.text = studentInformation.MediaURL
        
        return cell
    }
    
    func performAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
