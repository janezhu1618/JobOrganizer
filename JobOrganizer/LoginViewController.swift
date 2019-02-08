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

class LoginViewController: UIViewController {
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
            signInButton.setTitle(" Sign In ", for: .normal)
        } else {
            signInLabel.text = "Register"
            signInButton.setTitle(" Register ", for: .normal)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            guard email.hasSuffix(".com") || email.hasSuffix(".org") || email.hasSuffix(".net"), email.contains("@"), password.count >= 6 else { showAlert(title: "Invalid Format", message: "Make sure you enter an email and the password is at least 6 characters.")
                return
            }
            if isSignIn {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let _ = user {
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    } else if let error = error {
                        self.showAlert(title: "Invalid User", message: error.localizedDescription)
                    }
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let _ = user {
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    } else if let error = error {
                        self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                    }
                }
            }
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
}
