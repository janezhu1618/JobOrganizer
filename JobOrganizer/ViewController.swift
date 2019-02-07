//
//  ViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/6/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseDatabase

class ViewController: UIViewController {
    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var isSignIn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        //Flip the boolean
        isSignIn = !isSignIn
        //check the bool and set the labels
        if isSignIn {
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
        } else {
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            //check if signin or register
            if isSignIn {
                //sign in user
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    //check that user isn't nil
                    if let user = user {
                        //user is found
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    } else {
                        //error
                    }
                }
            } else {
                //register user
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let user = user {
                        //user is found, go to home screen
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    } else {
                        //error, check error and show message
                    }
                }
            }
        }

    }
}
