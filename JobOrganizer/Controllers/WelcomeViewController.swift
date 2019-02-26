//
//  ViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/25/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class WelcomeViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signInOrRegisterButton: UIButton!
    private var signInMethod: SignInMethod = .signIn
    
    private enum SignInMethod {
        case signIn
        case register
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func signInOrRegisterSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            signInOrRegisterButton.setTitle("Sign In", for: .normal)
            signInMethod = .signIn
        } else {
            signInOrRegisterButton.setTitle("Register", for: .normal)
            signInMethod = .register
        }
    }
    
    @IBAction func signInOrRegisterButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showAlert(title: "Error", message: "Email and password fields cannot be empty.")
            return
        }
        //TODO: move this elsewhere
        SVProgressHUD.show()
        switch signInMethod {
        case .signIn:
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToMainTab", sender: self)
                }
            }
        case .register:
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToMainTab", sender: self)
                }
            }
        }
    }
    
}

