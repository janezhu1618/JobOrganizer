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
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBoardTitleTextField.delegate = self
        descriptionTextField.delegate = self
    }
    

    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        guard let title = messageBoardTitleTextField.text,
            let description = messageBoardTitleTextField.text,
        let currentUser = DatabaseManager.getCurrentUser() else {
                showAlert(title: "Missing Info", message: "Message board title and description cannot be empty.")
                
                return
        }
        let messageBoardToAdd = MessageBoard(name: title, description: description, creatorID: currentUser.uid, lastUpdated: self.getTimestamp(), dbReferenceDocumentId: "")
        DatabaseManager.addMessageBoard(messageBoard: messageBoardToAdd)
        dismiss(animated: true, completion: nil)
    }

}

extension AddMessageBoardViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
