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
    @IBOutlet weak var addOrEditMessageBoardLabel: UILabel!
    @IBOutlet weak var addOrEditButton: UIButton!
    
    private var editMode = false
    public var messageBoard: MessageBoard?
    private var usersession: UserSession = (UIApplication.shared.delegate as! AppDelegate).usersession
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBoardTitleTextField.delegate = self
        descriptionTextView.delegate = self
        setupKeyboardToolbar()
        if let messageBoard = messageBoard {
            editMode = true
            messageBoardTitleTextField.text = messageBoard.title
            descriptionTextView.text = messageBoard.description
            addOrEditMessageBoardLabel.text = "Edit Message Board"
            addOrEditButton.setTitle("Save", for: .normal)
        }
    }
    

    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        guard let title = messageBoardTitleTextField.text,
            let description = descriptionTextView.text,
        let currentUser = usersession.getCurrentUser() else {
                showAlert(title: "Missing Info", message: "Message board title and description cannot be empty.")
                
                return
        }
        if editMode {
            if checkForAuthorization() {
                if title != messageBoard!.title {
                    DatabaseManager.updateMessageBoardInfo(messageBoard: messageBoard!, newInfo: title, editKey: MessageBoardKeys.title)
                } else if description != messageBoard!.description {
                    DatabaseManager.updateMessageBoardInfo(messageBoard: messageBoard!, newInfo: description, editKey: MessageBoardKeys.description)
                }
            } else {
                showAlert(title: "Unauthorized", message: "Only the original creator can edit message board.")
            }
        } else {
            let messageBoardToAdd = MessageBoard(name: title, description: description, creatorID: currentUser.uid, lastUpdated: self.getTimestamp(), dbReferenceDocumentId: "")
            DatabaseManager.addMessageBoard(messageBoard: messageBoardToAdd)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func checkForAuthorization() -> Bool {
        var isAuthorized = false
        if usersession.getCurrentUser()!.uid == messageBoard?.creatorID {
            isAuthorized = true
        }
        return isAuthorized
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
