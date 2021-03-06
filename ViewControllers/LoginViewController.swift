//
//  LoginViewController.swift
//  Repose
//
//  Created by Joseph Duran on 8/12/16.
//  Copyright © 2016 Repo Men. All rights reserved.
//

import UIKit
import Alamofire
import ResearchKit

class LoginViewController: UIViewController{
    
    // MARK: Properties
    
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    func checkRegistrationStatus(email:String, password:String)->Bool{
        Alamofire.request(.POST, "https://repose.herokuapp.com/api/v1/users", parameters:["user":["email":email, "password": password]])
            .responseJSON { response in
                switch response.result{
                case .Success:
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(response.data!, forKey: "bearerToken")
                    defaults.setBool(true, forKey:"hasReposeAccount")
                    self.performSegueWithIdentifier("dismissLogin", sender: self)
                    
                case .Failure:
//                    let alertView = UIAlertController(title: "Registration Problem",
//                        message: "invalid email or password." as String, preferredStyle:.Alert)
//                    let okAction = UIAlertAction(title: "retry!", style: .Default, handler: nil)
//                    alertView.addAction(okAction)
//                    self.presentViewController(alertView, animated: true, completion: nil)
                    self.performSegueWithIdentifier("dismissLogin", sender: self)

                }
        }
        return true
    }
    
    
    // ask the Repose server if the given credentials are valid.
    func checkLogin(email: String, password :String) -> Void{
        Alamofire.request(.POST, "https://repose.herokuapp.com/api/v1/sessions", parameters: ["session":["EMAIL": email,"PASSWORD": password]])
            .responseJSON { response in
                switch response.result{
                case .Success:
                    let myToken = response.result.value!["bearer_token"]!
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(myToken, forKey: "bearerToken")
                    self.performSegueWithIdentifier("dismissLogin", sender: self)
                case .Failure:
//                    let alertView = UIAlertController(title: "Registration Problem",
//                        message: "invalid email or password." as String, preferredStyle:.Alert)
//                    let okAction = UIAlertAction(title: "Sorry!", style: .Default, handler: nil)
//                    alertView.addAction(okAction)
//                    self.presentViewController(alertView, animated: true, completion: nil)
                    self.performSegueWithIdentifier("dismissLogin", sender: self)

                }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    
    override func viewDidAppear(animated: Bool) {
    }
    
    
    private func generateLogoLabel()->UILabel {
        let label = UILabel()
        label.text = "   R E P     S E        "
        label.font = UIFont.systemFontOfSize(50)
        label.textColor = UIColor.whiteColor()
        let bounds = self.view!.bounds
        label.center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        label.sizeToFit()
        label.layer.zPosition = 5
        return label
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        // check to see if the user has a login
        let hasLogin = NSUserDefaults.standardUserDefaults().valueForKey("hasReposeAccount") as? Bool
        // if they do, the button is a log in button
        if hasLogin == true {
            loginButton.setTitle("Log in", forState: UIControlState.Normal)
            
            loginButton.tag = loginButtonTag
        } else {
            // if they don't, their button is a create button
            
            loginButton.setTitle("Create an account", forState: UIControlState.Normal)
            loginButton.tag = createLoginButtonTag
        }
        
        // 3 Load the user's email if they have one
        if let storedEmail = NSUserDefaults.standardUserDefaults().valueForKey("email") as? String {
            emailTextField.text = storedEmail as String
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    // Ask the Repose server to authenticate login credentials. If it can,
    // store the bearer token in NSUserDefaults.
    // If it can't, display the error message.
    @IBAction func loginAction(sender: AnyObject) {
        
        // Display errors if users don't provide any information
        if (emailTextField.text == "" || passwordTextField.text == "") {
            let alertView = UIAlertController(title: "Login Problem",
                                              message: "Wrong username or password." as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Blank Fields", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            return;
        }
        
        // resign focus from email and password fields
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // if the sender is the registration button
        if sender.tag == createLoginButtonTag {
            checkRegistrationStatus(emailTextField.text!, password: passwordTextField.text!)
        } else if sender.tag == loginButtonTag {
            checkLogin(emailTextField.text!, password: passwordTextField.text!)
        }
    }
}

extension LoginViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}