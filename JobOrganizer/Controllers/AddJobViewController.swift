//
//  AddJobViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/26/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase

class AddJobViewController: UIViewController {
    
    @IBOutlet weak var applicationStatusPickerView: UIPickerView!
    private var tapGesture: UITapGestureRecognizer!
    private let jobsDatabase = Database.database().reference().child("Jobs")
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionNameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        applicationStatusPickerView.delegate = self
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboards))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func resignKeyboards() {
        companyNameTextField.endEditing(true)
        positionNameTextField.endEditing(true)
    }

    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        guard let companyName = companyNameTextField.text, let position = positionNameTextField.text
            else {
                showAlert(title: "Error", message: "Fields cannot be empty")
                return
        }
            let date = Date()
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withFullDate,
            .withFullTime,
            .withInternetDateTime,
            .withTimeZone,
            .withDashSeparatorInDate]
            let timeStamp = isoDateFormatter.string(from: date)
        let currentUser = Auth.auth().currentUser?.uid
        let jobDictionary = [JobDictionaryKeys.company : companyName,
                             JobDictionaryKeys.position : position,
                             JobDictionaryKeys.applicationPhase : "",
                             JobDictionaryKeys.jobPostingURL : "",
                             JobDictionaryKeys.notes : "",
                             JobDictionaryKeys.dateCreated : timeStamp,
                             JobDictionaryKeys.lastUpdated : timeStamp,
                             JobDictionaryKeys.contactPersonName : "",
                             JobDictionaryKeys.contactPersonNumber : "",
                             JobDictionaryKeys.contactPersonEmail : "",
                             JobDictionaryKeys.userID : currentUser]
        jobsDatabase.childByAutoId().setValue(jobDictionary) { (error, reference) in
            if error != nil {
                print(error!) //TODO: change this to some sort of feedback for user
            } else {
                
                print("job successfully saved") //SVProgressHUD
                
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
        private func addJob() {
//            let jobDictionary = [JobDictionaryKeys.company : companyNameTextField.text]
//            jobsDatabase.childByAutoId().setValue(jobDictionary) { (error, reference) in
//                if error != nil {
//                    print(error!) //TODO: change this to some sort of feedback for user
//                } else {
//
//                    print("job successfully saved") //SVProgressHUD
//
//                }
//            }
        }
    
}

extension AddJobViewController: UIPickerViewDelegate {
    
}
