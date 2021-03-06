//
//  JobTableViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 3/1/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import SVProgressHUD

class JobTableViewController: UITableViewController {

    @IBOutlet weak var jobPostingURLTextView: UITextView!
    @IBOutlet weak var applicationStatusPickerView: UIPickerView!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var contactEmailTextView: UITextView!
    @IBOutlet weak var contactNumberTextView: UITextView!
    @IBOutlet weak var contactNameTextField: UITextField!
    
    private var usersession: UserSession = (UIApplication.shared.delegate as! AppDelegate).usersession
    private let pickerData: [String] = ApplicationPhase.applicationPhasePickerData
    private var pickerSelection = ""
    private var newPickerSelection = false
    public var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupJobData()
        enableAllFields(false)
        setupKeyboardToolbar()
    }
    
    private func setupJobData() {
        companyTextField.text = job.company
        positionTextField.text = job.position
        contactNameTextField.text = job.contactPersonName
        jobPostingURLTextView.text = job.jobPostingURL
        contactNumberTextView.text = job.contactPersonNumber
        contactEmailTextView.text = job.contactPersonEmail
        notesTextView.text = job.notes
        applicationStatusPickerView.dataSource = self
        applicationStatusPickerView.delegate = self
        applicationStatusPickerView.selectRow(findCorrectApplicationStatusPickerViewRow(), inComponent: 0, animated: true)
    }
    
    private func findCorrectApplicationStatusPickerViewRow() -> Int {
        var returnNum = 0
        for (index,item) in pickerData.enumerated() {
            if item == job.applicationPhase {
                returnNum = index
            }
        }
        return returnNum
    }
    private func enableAllFields(_ trueOrFalse: Bool) {
        [companyTextField,
         positionTextField,
         contactNameTextField].forEach{ $0.isEnabled = trueOrFalse }
        [notesTextView,
         contactEmailTextView,
         jobPostingURLTextView,
         contactNumberTextView].forEach{ $0.isEditable = trueOrFalse }
        applicationStatusPickerView.isUserInteractionEnabled = trueOrFalse
    }

    @IBAction func editOrSaveButtonPressed(_ sender: UIBarButtonItem) {
        if navigationItem.rightBarButtonItem!.title == "Edit" {
            editMode()
        }
    }
    
    @objc private func editMode() {
        title = "Edit Mode"
        enableAllFields(true)
        navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveJobDetails))
    }
    
    @objc private func saveJobDetails() {
        enableAllFields(false)
        if companyTextField.text != job.company {
            guard let companyText = companyTextField.text else {
                print("company name cannot be blank")
                return }
            DatabaseManager.updateJob(newInfo: companyText, jobKey: JobDictionaryKeys.company, jobID: job.dbReferenceDocumentId)
        }
        if positionTextField.text != job.position {
            guard let positionText = positionTextField.text else {
                print("position cannot be blank")
                return }
            DatabaseManager.updateJob(newInfo: positionText, jobKey: JobDictionaryKeys.position, jobID: job.dbReferenceDocumentId)
        }
        if newPickerSelection {
            DatabaseManager.updateJob(newInfo: pickerSelection, jobKey: JobDictionaryKeys.applicationPhase, jobID: job.dbReferenceDocumentId)
            newPickerSelection = false
        }
        if jobPostingURLTextView.text != job.jobPostingURL {
            DatabaseManager.updateJob(newInfo: jobPostingURLTextView.text ?? "", jobKey: JobDictionaryKeys.jobPostingURL, jobID: job.dbReferenceDocumentId)
        }
        if contactNameTextField.text != job.contactPersonName {
            DatabaseManager.updateJob(newInfo: contactNameTextField.text ?? "", jobKey: JobDictionaryKeys.contactPersonName, jobID: job.dbReferenceDocumentId)
        }
        if contactNumberTextView.text != job.contactPersonNumber {
            DatabaseManager.updateJob(newInfo: contactNumberTextView.text ?? "", jobKey: JobDictionaryKeys.contactPersonNumber, jobID: job.dbReferenceDocumentId)
        }
        if contactEmailTextView.text != job.contactPersonEmail {
            DatabaseManager.updateJob(newInfo: contactEmailTextView.text ?? "", jobKey: JobDictionaryKeys.contactPersonEmail, jobID: job.dbReferenceDocumentId)
        }
        if notesTextView.text != job.notes {
            DatabaseManager.updateJob(newInfo: notesTextView.text ?? "", jobKey: JobDictionaryKeys.notes, jobID: job.dbReferenceDocumentId)
        }
        DatabaseManager.updateJob(newInfo: getTimestamp(), jobKey: JobDictionaryKeys.lastUpdated, jobID: job.dbReferenceDocumentId)
        SVProgressHUD.showSuccess(withStatus: "Job Updated")
        navigationItem.rightBarButtonItem! = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editMode))
        title = "Job Details"
    }


    fileprivate func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done
            , target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        [companyTextField,
         positionTextField,
         contactNameTextField].forEach{ $0.inputAccessoryView = toolbar }
        [notesTextView,
         contactNumberTextView,
         jobPostingURLTextView,
         contactEmailTextView].forEach{ $0.inputAccessoryView = toolbar }
    }
    
    @objc private func doneButtonAction() {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Last Updated: \(getReadableDate(fromTimestamp: job.lastUpdated))"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Created: \(getReadableDate(fromTimestamp: job.dateCreated))"
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveJobDetails()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        showDeleteActionSheet { (action) in
            self.deleteJob(job: self.job)
        }
    }
    
    private func deleteJob(job: Job) {
        guard let currentUser = usersession.getCurrentUser() else {
            print("no logged user")
            return }
        DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).document(job.dbReferenceDocumentId).delete()
        SVProgressHUD.showSuccess(withStatus: "Job deleted")
        navigationController?.popToRootViewController(animated: true)
    }
}

extension JobTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = pickerData[row]
        newPickerSelection = true
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
