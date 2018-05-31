//
//  SharedData.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import Foundation

class SharedData {
    static let sharedInstance = SharedData()
    var studentsInformation: [StudentInformation] = []
    var currentUser: StudentInformation?
    
    private init() {}
}
