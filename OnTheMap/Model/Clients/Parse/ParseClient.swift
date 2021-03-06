//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit

class ParseClient {
    
    // MARK: Properties
    var studentInformation : StudentInformation?
    var studentsInformation: [StudentInformation]?
    
    // MARK: Shared instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    // GET students locations
    func getStudentsLocations(parameters: [String: AnyObject], completionHandlerLocations: @escaping (_ result: [StudentInformation]?, _ error: NSError?)
        -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters, withPathExtension: Methods.StudentLocation))
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 2. Make the request */
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerLocations(nil, error)
            } else {
                if let results = parsedResult?[GetStudentJSONResponseKeys.StudentResult] as? [[String:AnyObject]] {
                    self.studentsInformation = StudentInformation.studentsInformationFromResults(results)
                    SharedData.sharedInstance.studentsInformation = self.studentsInformation!
                    completionHandlerLocations(self.studentsInformation, nil)
                } else {
                    completionHandlerLocations(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // GET student location
    func getStudentLocation(completionHandlerLocation: @escaping (_ result: StudentInformation?, _ error: NSError?)
        -> Void) {
        
        // Get current student info
        let accountKey = UdacityClient.sharedInstance().AccountKey
        let uniqueKeyStr = "{\"uniqueKey\":\"" + accountKey! + "\"}"
        let customAllowedSet = CharacterSet(charactersIn:":=\"#%/<>?@\\^`{|}").inverted
        let accountKeyEscapedString = uniqueKeyStr.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        let parameters = [SingleStudentParameterKeys.Where: accountKeyEscapedString as AnyObject]
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let uniqueKey = parameters[SingleStudentParameterKeys.Where] as? String
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=" + uniqueKey!)!)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 2. Make the request */
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            /* 3. Send the desired value(2) to completion handler */
            if let error = error {
                completionHandlerLocation(nil, error)
            } else {
                if let results = parsedResult?[GetStudentJSONResponseKeys.StudentResult] as? [[String:AnyObject]] {
                    let studentInformations = StudentInformation.studentsInformationFromResults(results)
                    // Get the first student information
                    if (studentInformations.count > 0) {
                        self.studentInformation = studentInformations[0]
                        SharedData.sharedInstance.currentUser = self.studentInformation!
                        completionHandlerLocation(self.studentInformation, nil)
                    }
                    else {
                        // Do nothing if student location is not there yet.
                    }
                } else {
                    completionHandlerLocation(nil, NSError(domain: "getStudentInformation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // POST student location
    func postStudentLocation(studentInformation: StudentInformation, completionHandlerPostLocation: @escaping (_ error: NSError?) -> Void) {
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let request = NSMutableURLRequest(url: parseURLFromParameters(nil, withPathExtension: Methods.StudentLocation))
        request.httpMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(studentInformation.UniqueKey)\", \"firstName\": \"\(studentInformation.FirstName)\", \"lastName\": \"\(studentInformation.LastName)\",\"mapString\": \"\(studentInformation.MapString)\", \"mediaURL\": \"\(studentInformation.MediaURL)\",\"latitude\": \(studentInformation.Latitude), \"longitude\": \(studentInformation.Longitude)}".data(using: String.Encoding.utf8)
        
        /* 2. Make the request */
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerPostLocation(error)
            } else {
                
                /* GUARD: Is the createdAt key in our result? */
                guard let createdAt = parsedResult?[GetStudentJSONResponseKeys.CreatedAt] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                    return
                }
                /* GUARD: Is the objectID key in our result? */
                guard let objectID = parsedResult?[GetStudentJSONResponseKeys.ObjectID] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                    return
                }
                if (objectID != "" && createdAt != "") {
                    completionHandlerPostLocation(nil)
                } else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                }
            }
        }
    }
    
    // PUT student location
    func putStudentLocation(studentInformation: StudentInformation, completionHandlerPutLocation: @escaping (_ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let request = NSMutableURLRequest(url: parseURLFromParameters(nil, withPathExtension: Methods.StudentLocation + "/\(studentInformation.ObjectID)"))
        request.httpMethod = "PUT"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(studentInformation.UniqueKey)\", \"firstName\": \"\(studentInformation.FirstName)\", \"lastName\": \"\(studentInformation.LastName)\",\"mapString\": \"\(studentInformation.MapString)\", \"mediaURL\": \"\(studentInformation.MediaURL)\",\"latitude\": \(studentInformation.Latitude), \"longitude\": \(studentInformation.Longitude)}".data(using: String.Encoding.utf8)
        
        /* 2. Make the request */
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerPutLocation(error)
            } else {
                
                /* GUARD: Is the updatedAt key in our result? */
                guard let updatedAt = parsedResult?[GetStudentJSONResponseKeys.UpdatedAt] as? String else {
                    completionHandlerPutLocation(NSError(domain: "PUT StudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse PUT Student Location"]))
                    return
                }
                if updatedAt != "" {
                    completionHandlerPutLocation(nil)
                } else {
                    completionHandlerPutLocation(NSError(domain: "PUT StudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse PUT Student Location"]))
                }
            }
        }
    }

    private func performRequest(request: NSMutableURLRequest,
                                completionHandlerRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
        -> URLSessionDataTask {
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                func displayError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    displayError("There was an error with your request: \(error!)")
                    return
                }
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    displayError("Your request returned a status code: \(String(describing: httpError))")
                    return
                }
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    displayError("No data was returned by the request!")
                    return
                }
                self.convertDataWithCompletionHandler(data, completionHandlerConvertData: completionHandlerRequest)
            }
            task.resume()
            return task
    }
    
    // Convert raw JSON
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerConvertData(parsedResult, nil)
    }
    
    // Create a URL from parameters
    private func parseURLFromParameters(_ parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
}
