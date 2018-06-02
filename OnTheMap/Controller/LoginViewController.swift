//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ion M on 5/27/18.
//  Copyright © 2018 Ion M. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var fbLoginStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        // Log out if the user was logged in when terminated the app
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        
        // Add FB login button
        let fbLoginButton = FBSDKLoginButton()
        fbLoginStackView.addArrangedSubview(fbLoginButton)
        
        // Set the delegates
        fbLoginButton.delegate = self
        emailTextField.delegate = TextFieldDelegate.sharedInstance
        passwordTextField.delegate = TextFieldDelegate.sharedInstance
    }
    
    @IBAction func performLogin(_ sender: Any) {
        activityIndicator.startAnimating()
        if (emailTextField.text! == "" || passwordTextField.text! == "") {
            let alert = UIAlertController(title: "Alert", message: "Please enter email and password.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            activityIndicator.stopAnimating()
            return
        }
        
        UdacityClient.sharedInstance().performUdacityLogin(emailTextField.text!, passwordTextField.text!, completionHandlerLogin: { (error) in
            if let error = error {
                self.performAlert(error.localizedDescription)
            }
            else {
                self.getCurrentUserInfo()
                self.completeLogin()
            }
        })
    }
    
    @IBAction func performSignUp(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!, options: [:])
    }
    
    private func completeLogin() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // Show alert if login failed
    func performAlert(_ messageString: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getCurrentUserInfo() {
        ParseClient.sharedInstance().getStudentLocation(completionHandlerLocation: {(studentInfo, error) in
            if (error != nil) {
                self.performAlert("Fail to get user information")
            }
        })
    }
    
    func performFBLogin(_ fbToken: String) {
        UdacityClient.sharedInstance().performFacebookLogin(fbToken, completionHandlerFBLogin: { (error) in
            if (error == nil) {
                self.getCurrentUserInfo()
                self.completeLogin()
            }
            else {
                self.performAlert("Invalid login or password")
            }
        })
    }
    
    // Dismiss keyboard on screen touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Loged out from facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            performAlert("Fail to login using facebook")
            return
        }
        if result.token != nil {
            self.performFBLogin(result.token.tokenString)
        }
    }
}
