//
//  AddMessageBoardViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit

class AddMessageBoardViewController: UIViewController {

    @IBOutlet weak var messageBoardTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    private var usersession: UserSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBoardTitleTextField.delegate = self
        descriptionTextView.delegate = self
        setupKeyboardToolbar()
        usersession = (UIApplication.shared.delegate as! AppDelegate).usersession
    }
    

    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        guard let title = messageBoardTitleTextField.text,
            let description = messageBoardTitleTextField.text,
        let currentUser = usersession.getCurrentUser() else {
                showAlert(title: "Missing Info", message: "Message board title and description cannot be empty.")
                
                return
        }
        let messageBoardToAdd = MessageBoard(name: title, description: description, creatorID: currentUser.uid, lastUpdated: self.getTimestamp(), dbReferenceDocumentId: "")
        DatabaseManager.addMessageBoard(messageBoard: messageBoardToAdd)
        dismiss(animated: true, completion: nil)
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done
            , target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        messageBoardTitleTextField.inputAccessoryView = toolbar
        descriptionTextView.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonAction() {
        view.endEditing(true)
    }

}

extension AddMessageBoardViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension AddMessageBoardViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}
