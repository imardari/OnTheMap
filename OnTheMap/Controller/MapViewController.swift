//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        getStudentsInformation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    func getStudentsInformation() {
        activityIndicator.startAnimating()
        
        let parameters = [
            ParseClient.MultipleStudentParameterKeys.Limit: "100",
            ParseClient.MultipleStudentParameterKeys.Order: "-updatedAt"
        ]
        
        ParseClient.sharedInstance().getStudentsLocations(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentsInformation, error) in
            if let studentsInformation = studentsInformation {
                self.updateUIMapAnnotation(location: studentsInformation)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
            } else {
                self.performAlert("There was an error retrieving student data")
            }
        })
    }
    
    private func updateUIMapAnnotation(location: [StudentInformation]) {
        
        // Clean up annotations
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        // Create an MKPointAnnotation array
        var annotations = [MKPointAnnotation]()

        for dictionary in location {
            let lat = CLLocationDegrees(dictionary.Latitude as Double)
            let long = CLLocationDegrees(dictionary.Longitude as Double)
            
            // Create a CLLocationCoordinates2D instance
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.FirstName as String
            let last = dictionary.LastName as String
            let mediaURL = dictionary.MediaURL as String
            
            // Create the annotation and set its properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // If the annotation has a title and subtitle, add it to annotations array
            if (annotation.title != "" && annotation.subtitle != "") {
                annotations.append(annotation)
            }
        }
        
        DispatchQueue.main.async {
            // Add the annotations to the map
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func performAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // Open the system browser to the URL specified in the annotationViews subtitle property
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: { (isSuccess) in
                    if (isSuccess == false) {
                        self.performAlert("The URL is not valid. Please provide a valid URL.")
                    }
                }
                )}
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (fullyRendered) {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
