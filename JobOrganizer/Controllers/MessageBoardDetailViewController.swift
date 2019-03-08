//
//  MessageBoardViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class MessageBoardDetailViewController: UIViewController {
    
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var composeViewHeight: NSLayoutConstraint!
  
    public var messageBoard: MessageBoard!
    private var messageArray = [Message]()
    private var listener: ListenerRegistration!
    private let usersession: UserSession = (UIApplication.shared.delegate as! AppDelegate).usersession

    override func viewDidLoad() {
        super.viewDidLoad()
        title = messageBoard.title
        messageTextView.delegate = self
        setUpTableView()
        configureTableView()
        retrieveMessages()
    }
    
    private func setUpTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        messageTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
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
                messages.sort{ $0.timeStamp < $1.timeStamp }
                self.messageArray = messages
                self.configureTableView()
                self.checkForEmptyState()
                self.messageTableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom(){
        guard messageArray.count > 0 else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func tableViewTapped() {
        messageTextView.endEditing(true)
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let messageBodyText = messageTextView.text else {
            showAlert(title: "Message Empty", message: "Message body text cannot be empty")
            return
        }
        messageTextView.endEditing(true)
        postButton.isEnabled = false
        messageTextView.isEditable = false
        guard let currentUser = usersession.getCurrentUser() else {
            print("no current user logged in")
            return }
        let message = Message(messageBody: messageBodyText,
                              imageURL: "",
                              senderID: currentUser.uid,
                              senderEmail: currentUser.email!,
                              timeStamp: getTimestamp(),
                              dbReferenceDocumentId: "")
        DatabaseManager.postMessage(message: message, messageBoard: messageBoard)
        postButton.isEnabled = true
        messageTextView.isEditable = true
        messageTextView.text = ""
    }
    
    @IBAction func moreOptionsButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "", message: "What would you like to do with this message board?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "AddMessageBoardViewController") as? AddMessageBoardViewController else { return }
            vc.modalPresentationStyle = .overCurrentContext
            vc.messageBoard = self.messageBoard
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            if self.checkForAuthorization() {
                self.showDestructionAlert(title: "Confirm Deletion", message: "Are you sure you want to delete the message board", style: .alert, handler: { (action) in
                    DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(self.messageBoard.dbReferenceDocumentId).delete()
                    self.navigationController?.popToRootViewController(animated: true)
                })
            } else {
                self.showAlert(title: "Unauthorized", message: "Only the original creator can delete message board.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func checkForAuthorization() -> Bool {
        var isAuthorized = false
        if usersession.getCurrentUser()!.uid == messageBoard?.creatorID {
            isAuthorized = true
        }
        return isAuthorized
    }
}

extension MessageBoardDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageArray[indexPath.row]
        if message.senderID != usersession.getCurrentUser()!.uid {
            guard let otherPeoplesMessageCell = messageTableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else {
                    fatalError("otherPeoplesMessageCell cannot be dequeued")
                }
                otherPeoplesMessageCell.messageBackground.layer.cornerRadius = 10.0
                otherPeoplesMessageCell.messageBackground.layer.masksToBounds = true
                DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(message.senderID).getDocument { (snapshot, error) in
                    if let error = error {
                        print("Error retrieving other user's profile pics - \(error)")
                    } else {
                        let photo = snapshot!.get("imageURL") as! String
                        if let photoURL = URL(string: photo) {
                            otherPeoplesMessageCell.messageUserProfilePicture.kf.setImage(with: photoURL, placeholder: UIImage(named: "placeholderProfile")!)
                        }
                    }
                }
            otherPeoplesMessageCell.messageSender.text = message.senderEmail
            otherPeoplesMessageCell.messageBody.text = message.messageBody
            return otherPeoplesMessageCell
        } else {
            guard let myMessageCell = messageTableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MyMessageCell else {
                fatalError("myMessageCell cannot be dequeued")
                }
                myMessageCell.messageBackground.layer.cornerRadius = 10.0
                myMessageCell.messageBackground.layer.masksToBounds = true
                if let photoURL = usersession.getCurrentUser()!.photoURL {
                    myMessageCell.messageUserProfilePicture.kf.setImage(with: photoURL, placeholder: UIImage(named: "placeholderProfile")!)
                }
                myMessageCell.messageSender.text = message.senderEmail
                myMessageCell.messageBody.text = message.messageBody
                return myMessageCell
            }
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if messageArray[indexPath.row].imageURL != "" {
            return 300
        }
        return UITableView.automaticDimension
    }
    
    private func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
}

extension MessageBoardDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) {
            self.scrollToBottom()
            self.composeViewHeight.constant = 300
            self.view.layoutIfNeeded()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) {
            self.composeViewHeight.constant = 50
            self.view.layoutIfNeeded()
        }
    }
}
