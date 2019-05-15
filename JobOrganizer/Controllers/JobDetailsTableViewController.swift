//
//  JobDetailsTableViewController.swift
//  FirebaseAuth
//
//  Created by Jane Zhu on 2/12/19.
//

import UIKit

class JobDetailsTableViewController: UITableViewController {

    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var applicationStatusTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var jobDescriptionTextView: UITextView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    private var job: Job?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let jobExists = job {
            companyNameTextField.text = jobExists.companyName
        }
    }
    
    fileprivate func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done
            , target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        companyNameTextField.inputAccessoryView = toolbar
        positionTextField.inputAccessoryView = toolbar
        applicationStatusTextField.inputAccessoryView = toolbar
        notesTextView.inputAccessoryView = toolbar
        jobDescriptionTextView.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonAction() {
        self.view.endEditing(true)
    }

    
}
