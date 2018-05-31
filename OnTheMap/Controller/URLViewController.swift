//
//  URLViewController.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit
import MapKit

class URLViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var location: String!
    var longitude: Double?
    var latitude: Double?
    var mediaURLTextField: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        updateMapView()
    }
    
    @IBAction func performSubmit(_ sender: Any) {
        
        if (mediaURLTextField == "") {
            let alert = UIAlertController(title: "Alert", message: "Please enter media url.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let longitude = longitude {
            if let latitude = latitude {
                if let userInfo = ParseClient.sharedInstance().studentInformation {
                    var newUserInfo = userInfo
                    newUserInfo.Longitude = longitude
                    newUserInfo.Latitude = latitude
                    newUserInfo.MediaURL = mediaURLTextField!
                    newUserInfo.MapString = location
                    
                    // PUT
                    if (userInfo.Longitude != longitude || userInfo.Latitude != latitude) {
                        ParseClient.sharedInstance().putStudentLocation(studentInformation: newUserInfo, completionHandlerPutLocation: { (error) in
                            if (error == nil) {
                                self.performUIUpdate()
                            }
                            else {
                                self.alertMapError("Fail to update student location")
                            }
                        })
                    }
                    else {
                        // POST
                        ParseClient.sharedInstance().postStudentLocation(studentInformation: newUserInfo, completionHandlerPostLocation: { (error) in
                            if (error == nil) {
                                self.performUIUpdate()
                            }
                            else {
                                self.alertMapError("Fail to create student location")
                            }
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func performCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateMapView() {
        loadingIndicator.startAnimating()
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placeMarks, error) in
            
            if (error == nil) {
                if ((placeMarks?.count)! == 1) {
                    let placeMark = placeMarks![0]
                    
                    self.longitude = placeMark.location?.coordinate.longitude
                    self.latitude = placeMark.location?.coordinate.latitude
                    
                    // Create a CLLocationCoordinates2D instance
                    let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                    
                    // Set the coordinate span and region
                    let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    let coordinateRegion = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
                    
                    // Set the annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    
                    DispatchQueue.main.async {
                        self.mapView.region = coordinateRegion
                        self.mapView.addAnnotation(annotation)
                    }
                }
                else if ((placeMarks?.count)! == 0) {
                    self.alertMapError("Location is not found.")
                }
                else {
                    self.alertMapError("Multiple locations found.")
                }
            }
            else {
                self.alertMapError("Error getting location.")
            }
        }
    }
    
    func performUIUpdate() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertMapError(_ alertMessage: String) {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension URLViewController: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (fullyRendered) {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}
