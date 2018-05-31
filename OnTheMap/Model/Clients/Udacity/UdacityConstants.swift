//
//  UdacityConstant.swift
//  OnTheMap
//
//  Created by Ion M on 5/28/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        static let AuthorizationURL = "https://www.udacity.com/api/session"
    }
    
    // MARK: Parameter keys
    struct UdacityParameterKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: Account keys
    struct UdacityAccountKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
    }
    
    // MARK: Session keys
    struct SessionKeys {
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
    }
}
