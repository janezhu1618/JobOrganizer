//
//  MessageBoardViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SVProgressHUD

class MessageBoardDetailoViewController: UIViewController {
    //TODO: handle empty state
    
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var composeViewHeight: NSLayoutConstraint!
    public var messageBoard: MessageBoard!
    private var messageDatabase: DatabaseReference {
        return Database.database().reference().child("Messages").child(messageBoard.title)
    }
    private var messageArray = [Message]()
    private let currentUserEmail = Auth.auth().currentUser?.email
    private var listener: ListenerRegistration!
    
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
    
    private func checkForEmptyState() {
        messageTableView.backgroundView = messageArray.isEmpty ? emptyStateView : nil
    }
    
    private func retrieveMessages() {
        messageArray.removeAll()
        listener = DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).collection(DatabaseKeys.MessagesCollectionKey).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                var messages = [Message]()
                for message in snapshot.documents {
                    let messageToAdd = Message(dict: message.data() as! [String : String])
                    messages.append(messageToAdd)
                }
                self.messageArray = messages
                self.configureTableView()
                self.checkForEmptyState()
                self.messageTableView.reloadData()
            }
        }
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
        guard let currentUser = Auth.auth().currentUser else {
            print("no current user logged in")
            return }
        let message = Message(messageBody: messageBodyText,
                              imageURL: "",
                              senderID: currentUser.uid,
                              senderEmail: currentUser.email!,
                              dbReferenceDocumentId: "")
        DatabaseManager.postMessage(message: message, messageBoard: messageBoard)
        //SVProgressHUD.showSuccess(withStatus: "Message posted")
        postButton.isEnabled = true
        messageTextField.isEnabled = true
        messageTextField.text = ""
//        let messageDictionary = [MessageDictionaryKeys.senderID : currentUserEmail, MessageDictionaryKeys.messageBody : messageBodyText, MessageDictionaryKeys.imageURL : ""]
//        messageDatabase.childByAutoId().setValue(messageDictionary) { (error, reference) in
//            if error != nil {
//                SVProgressHUD.dismiss()
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                SVProgressHUD.dismiss()
//                SVProgressHUD.showSuccess(withStatus: "Message posted")
//                self.postButton.isEnabled = true
//                self.messageTextField.isEnabled = true
//                self.messageTextField.text = ""
//            }
//        }
    }
    
//    private func retrieveMessages() {
//        messageDatabase.observe(.childAdded) { (snapshot) in
//            let snapshotValue = snapshot.value as! Dictionary<String, String>
//            let message = Message.init(messageBody: snapshotValue[MessageDictionaryKeys.messageBody]!,
//                                       imageURL: snapshotValue[MessageDictionaryKeys.imageURL]!,
//                                       senderID: snapshotValue[MessageDictionaryKeys.sender
//                ]!)
//            self.messageArray.append(message)
//            self.configureTableView()
//            self.messageTableView.reloadData()
//        }
//    }
    
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
        cell.messageSender.text = message.senderID
        cell.messageBody.text = message.messageBody
        if let currentUser = Auth.auth().currentUser {
            if let photoURL = currentUser.photoURL {
                cell.messageUserProfilePicture.kf.setImage(with: photoURL, placeholder: UIImage(named: "placeholderProfile")!)
            }
        }
        if cell.messageSender.text == currentUserEmail {
            cell.messageBackground.backgroundColor = .yellow
        } else {
            cell.messageBackground.backgroundColor = .lightGray
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
