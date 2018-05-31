//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

struct StudentInformation {
    
    // MARK: Properties
    let FirstName: String
    let LastName: String
    let CreatedAt: String
    let UpdatedAt: String
    let ObjectID: String
    let UniqueKey: String
    var Latitude: Double
    var Longitude: Double
    var MapString: String
    var MediaURL: String
    
    // MARK: Initializers
    init?(dictionary: [String:AnyObject]) {
        if let createdAt = dictionary[ParseClient.GetStudentJSONResponseKeys.CreatedAt] as? String {
            CreatedAt = createdAt
        }
        else {
            return nil
        }
        
        if let firstName = dictionary[ParseClient.GetStudentJSONResponseKeys.FirstName] as? String {
            FirstName = firstName
        }
        else {
            return nil
        }
        
        if let lastName = dictionary[ParseClient.GetStudentJSONResponseKeys.LastName] as? String {
            LastName = lastName
        }
        else {
            return nil
        }
        
        if let latitude = dictionary[ParseClient.GetStudentJSONResponseKeys.Latitude] as? Double {
            Latitude = latitude
        }
        else {
            return nil
        }
        
        if let longitude = dictionary[ParseClient.GetStudentJSONResponseKeys.Longitude] as? Double {
            Longitude = longitude
        }
        else {
            return nil
        }
        
        if let mapString = dictionary[ParseClient.GetStudentJSONResponseKeys.MapString] as? String {
            MapString = mapString
        }
        else {
            return nil
        }
        
        if let mediaURL = dictionary[ParseClient.GetStudentJSONResponseKeys.MediaURL] as? String {
            MediaURL = mediaURL
        } else {
            return nil
        }
        
        if let objectID = dictionary[ParseClient.GetStudentJSONResponseKeys.ObjectID] as? String {
            ObjectID = objectID
        } else {
            return nil
        }
        
        if let uniqueKey = dictionary[ParseClient.GetStudentJSONResponseKeys.UniqueKey] as? String {
            UniqueKey = uniqueKey
        } else {
            return nil
        }
        
        if let updatedAt = dictionary[ParseClient.GetStudentJSONResponseKeys.UpdatedAt] as? String {
            UpdatedAt = updatedAt
        } else {
            return nil
        }
    }
    
    // Create an array of StudentInformation objects
    static func studentsInformationFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        var studentsInformation = [StudentInformation]()
        
        for result in results {
            if let studentInformation = StudentInformation(dictionary: result) {
                studentsInformation.append(studentInformation)
            }
        }
        return studentsInformation
    }
}
