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
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var composeViewHeight: NSLayoutConstraint!
  
    public var messageBoard: MessageBoard!
    private var messageArray = [Message]()
    private var listener: ListenerRegistration!
    private let usersession: UserSession = (UIApplication.shared.delegate as! AppDelegate).usersession
    private var imagePickerViewController: UIImagePickerController!
    //private var isImageFromCamera: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = messageBoard.title
        messageTextField.delegate = self
        setUpTableView()
        configureTableView()
        retrieveMessages()
        imagePickerViewController = UIImagePickerController()
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.delegate = self
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
        messageTextField.isEnabled = true
        messageTextField.text = ""
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
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        print("image button pressed")
    }
    
    private func showImagePickerViewController() {
        present(imagePickerViewController, animated: true, completion: nil)
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
                otherPeoplesMessageCell.messageSender.text = message.senderEmail
                otherPeoplesMessageCell.messageBody.text = message.messageBody
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
            return otherPeoplesMessageCell
        } else {
            guard let myMessageCell = messageTableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MyMessageCell else {
                fatalError("myMessageCell cannot be dequeued")
                }
                myMessageCell.messageBackground.layer.cornerRadius = 10.0
                myMessageCell.messageBackground.layer.masksToBounds = true
                myMessageCell.messageSender.text = message.senderEmail
                myMessageCell.messageBody.text = message.messageBody
                if let photoURL = usersession.getCurrentUser()!.photoURL {
                    myMessageCell.messageUserProfilePicture.kf.setImage(with: photoURL, placeholder: UIImage(named: "placeholderProfile")!)
                }
            return myMessageCell
        }
    }
    
    private func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
}

extension MessageBoardDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.composeViewHeight.constant = 300
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

extension MessageBoardDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
            
        }
        if let selectedImage = selectedImageFromPicker {
//            profileImageButton.setImage(selectedImage, for: .normal)
//            guard let data = selectedImage.jpegData(compressionQuality: 1) else { print("unable to convert selected image to image data")
//                return
//            }
//            StorageManager.uploadProfileImage(data)
//            if isImageFromCamera && saveImageFromCamera {
//                UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//            }
        }
        dismiss(animated: true, completion: nil)
            //TODO: post message with image URL
            //TODO: storagemanager upload image
        } else {
            print("edited image is nil")
        }
        dismiss(animated: true, completion: nil)
    }
}
