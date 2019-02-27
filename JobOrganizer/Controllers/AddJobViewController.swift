//
//  AddJobViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/26/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddJobViewController: UIViewController {
    
    @IBOutlet weak var applicationStatusPickerView: UIPickerView!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionNameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    private var tapGesture: UITapGestureRecognizer!
    private let jobsDatabase = Database.database().reference().child("Jobs")
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
        addJob()
    }
    
        private func addJob() {
            guard let companyName = companyNameTextField.text, let position = positionNameTextField.text
                else {
                    showAlert(title: "Error", message: "Fields cannot be empty")
                    return
            }
            SVProgressHUD.show()
            let date = Date()
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withFullDate,
                                              .withFullTime,
                                              .withInternetDateTime,
                                              .withTimeZone,
                                              .withDashSeparatorInDate]
            let timeStamp = isoDateFormatter.string(from: date)
            guard let currentUser = Auth.auth().currentUser else {
                print("no current user logged in")
                return }
            let job = Job(company: companyName,
                          position: position,
                          jobPostingURL: "",
                          notes: "",
                          applicationPhase: applicationStatus,
                          dateCreated: timeStamp,
                          lastUpdated: timeStamp,
                          contactPersonName: "",
                          contactPersonNumber: "",
                          contactPersonEmail: "",
                          userID: currentUser.uid,
                          dbReferenceDocumentId: "")
        DatabaseManager.postJobToDatabase(job: job)
        SVProgressHUD.showSuccess(withStatus: "Job added.")
        dismiss(animated: true, completion: nil)
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
