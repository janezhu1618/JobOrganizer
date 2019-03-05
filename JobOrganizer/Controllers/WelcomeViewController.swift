//
//  ViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/25/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
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
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToMainTab", sender: self)
                }
            }
        case .register:
            Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                } else if let authDataResult = authDataResult {
                    guard let username = authDataResult.user.email else {
                        print("no email entered")
                        return
                    }
                    let userData: [String : Any] = ["userId"      : authDataResult.user.uid,
                                    "email"       : authDataResult.user.email ?? "",
                                    "displayName" : authDataResult.user.displayName ?? "",
                                    "imageURL"    : authDataResult.user.photoURL ?? "",
                                    "username"    : username
                        ]
                    DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(authDataResult.user.uid).setData(userData, completion: { (error) in
                            if let error = error {
                                print("error creating user profile \(error.localizedDescription)")
                            }
                        })
                    self.performSegue(withIdentifier: "goToMainTab", sender: self)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
}

