//
//  MessageBoardViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MessageBoardDetailoViewController: UIViewController {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var composeViewHeight: NSLayoutConstraint!
    public var messageBoard: MessageBoard!
    private var messageDatabase: DatabaseReference {
        return Database.database().reference().child("Messages").child(messageBoard.name)
    }
    private var messageArray = [Message]()
    private let currentUserEmail = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        configureTableView()
        retrieveMessages()
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let messageBodyText = messageTextField.text else {
            showAlert(title: "Message Empty", message: "Message body text cannot be empty")
            return
        }
        messageTextField.endEditing(true)
        postButton.isEnabled = false
        messageTextField.isEnabled = false
        SVProgressHUD.show()
        let messageDictionary = [MessageDictionaryKeys.sender : currentUserEmail, MessageDictionaryKeys.messageBody : messageBodyText, MessageDictionaryKeys.imageURL : ""]
        messageDatabase.childByAutoId().setValue(messageDictionary) { (error, reference) in
            if error != nil {
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "Message posted")
                self.postButton.isEnabled = true
                self.messageTextField.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    private func retrieveMessages() {
        messageDatabase.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let message = Message.init(messageBody: snapshotValue[MessageDictionaryKeys.messageBody]!,
                                       imageURL: snapshotValue[MessageDictionaryKeys.imageURL]!,
                                       sender: snapshotValue[MessageDictionaryKeys.sender
                ]!)
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
}

extension MessageBoardDetailoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = messageTableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else {
            fatalError("Message Cell cannot be dequeued")
        }
        let message = messageArray[indexPath.row]
        cell.messageSender.text = message.sender
        cell.messageBody.text = message.messageBody
        cell.messageUserProfilePicture.image = UIImage(named: "placeholderProfile")
        if cell.messageSender.text == currentUserEmail {
            cell.messageBackground.backgroundColor = .lightGray
        } else {
            cell.messageBackground.backgroundColor = .yellow
        }
        return cell
    }
    
    private func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
}

extension MessageBoardDetailoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.composeViewHeight.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.composeViewHeight.constant = 50
            self.view.layoutIfNeeded()
        }
    }
}
