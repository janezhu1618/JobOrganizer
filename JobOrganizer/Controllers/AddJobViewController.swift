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
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionNameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var basicQuestionsView: UIView!
    @IBOutlet var detailQuestionsView: UIView!
    @IBOutlet weak var contactPersonName: UITextField!
    @IBOutlet weak var contactPersonEmail: UITextField!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var contactPersonPhone: UITextField!
    
    private var tapGesture: UITapGestureRecognizer!
    private let pickerData: [String] = [ ApplicationPhase.interested.rawValue, ApplicationPhase.applicationSent.rawValue, ApplicationPhase.phoneInterview.rawValue, ApplicationPhase.inPersonInterview.rawValue, ApplicationPhase.whiteboarding.rawValue, ApplicationPhase.jobOffer.rawValue, ApplicationPhase.itsComplicated.rawValue]
    private var applicationStatus = ApplicationPhase.interested.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        applicationStatusPickerView.delegate = self
        applicationStatusPickerView.dataSource = self
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
        if applicationStatus == ApplicationPhase.phoneInterview.rawValue {
            basicQuestionsView.removeFromSuperview()
           // view.insertSubview(detailQuestionsView, aboveSubview: basicQuestionsView)
            //view.remove(basicQuestionsView)
          view.addSubview(detailQuestionsView)
            detailQuestionsView.translatesAutoresizingMaskIntoConstraints = false
            detailQuestionsView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            detailQuestionsView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        addJob()
    }
    
    private func addJob() {
        guard let companyName = companyNameTextField.text, let position = positionNameTextField.text
            else {
                showAlert(title: "Error", message: "Fields cannot be empty")
                return
        }
        guard let currentUser = Auth.auth().currentUser else {
            print("no current user logged in")
            return }
        let job = Job(company: companyName,
                        position: position,
                        jobPostingURL: "",
                        notes: "",
                        applicationPhase: applicationStatus,
                        dateCreated: getTimestamp(),
                        lastUpdated: getTimestamp(),
                        contactPersonName: contactPersonName.text!,
                        contactPersonNumber: contactPersonPhone.text!,
                        contactPersonEmail: contactPersonEmail.text!,
                        userID: currentUser.uid,
                        dbReferenceDocumentId: "")
        DatabaseManager.postJob(job: job)
       // dismiss(animated: true, completion: nil)
        }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddJobViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        applicationStatus = pickerData[row]
    }
}
