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
    private var isImageFromCamera: Bool = false
    private var saveImageFromCamera: Bool = false
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomTap)))
        return imageView
    }()
    
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
        if let saveImageSetting = UserDefaults.standard.object(forKey: UserDefaultsKeys.saveCameraImage) as? Bool {
            saveImageFromCamera = saveImageSetting
        }
    }
    
    @objc private func zoomTap() {
        print("handling zoom tap")
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
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerViewController.sourceType = .photoLibrary
            showImagePickerViewController()
        } else {
            let alert = UIAlertController(title: "", message: "Upload image from?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.imagePickerViewController.sourceType = .camera
                self.isImageFromCamera = true
                self.showImagePickerViewController()
            }))
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                self.imagePickerViewController.sourceType = .photoLibrary
                self.isImageFromCamera = false
                self.showImagePickerViewController()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
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
            if message.messageBody == "" {
                otherPeoplesMessageCell.messageBackground.addSubview(messageImageView)
                [messageImageView.leftAnchor.constraint(equalTo: otherPeoplesMessageCell.messageBackground.leftAnchor),
                 messageImageView.rightAnchor.constraint(equalTo: otherPeoplesMessageCell.messageBackground.rightAnchor),
                 messageImageView.topAnchor.constraint(equalTo: otherPeoplesMessageCell.messageBackground.topAnchor),
                 messageImageView.bottomAnchor.constraint(equalTo: otherPeoplesMessageCell.messageBackground.bottomAnchor)
                    ].forEach{ $0.isActive = true }
                otherPeoplesMessageCell.messageBody.isHidden = true
                if let photoURL = URL(string: message.imageURL) {
                    print(photoURL)
                    messageImageView.kf.setImage(with: photoURL, placeholder: UIImage(named: "placeholderProfile")!)
                    messageImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
                    
//                    tutorial from: https://www.youtube.com/watch?v=FqDVKW9Rn_M helped me with this part...
                }
            } else {
                otherPeoplesMessageCell.messageBody.isHidden = false
                otherPeoplesMessageCell.messageSender.text = message.senderEmail
                otherPeoplesMessageCell.messageBody.text = message.messageBody
            }
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
            if message.messageBody == "" {
                myMessageCell.messageBackground.addSubview(messageImageView)
                [messageImageView.leftAnchor.constraint(equalTo: myMessageCell.messageBackground.leftAnchor),
                 messageImageView.rightAnchor.constraint(equalTo: myMessageCell.messageBackground.rightAnchor),
                 messageImageView.topAnchor.constraint(equalTo: myMessageCell.messageBackground.topAnchor),
                 messageImageView.bottomAnchor.constraint(equalTo: myMessageCell.messageBackground.bottomAnchor)
                    ].forEach{ $0.isActive = true }

                if let photoURL = URL(string: message.imageURL) {
                    messageImageView.kf.setImage(with: photoURL, placeholder: UIImage(named: "placeholderProfile")!)
                }
                myMessageCell.messageBody.isHidden = true
            } else {
                myMessageCell.messageBody.isHidden = false
                myMessageCell.messageSender.text = message.senderEmail
                myMessageCell.messageBody.text = message.messageBody
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

extension MessageBoardDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            guard let currentUser = usersession.getCurrentUser() else {
                print("no current user logged in")
                return }
            guard let data = selectedImage.jpegData(compressionQuality: 1) else {
                print("unable to convert selected message image to image data")
                return
            }
            let imageName = NSUUID().uuidString
            let imageReference = Storage.storage().reference().child(StorageKeys.MessageImages).child("\(imageName).jpg")
            StorageMetadata().contentType = "image/jpeg"
            imageReference.putData(data, metadata: StorageMetadata()) { (metadata, error) in
                guard let _ = metadata else {
                    print("error uploading data")
                    return
                }
                imageReference.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        let returnURL = url!.absoluteString
                        var newMessage = Message(messageBody: "", imageURL: returnURL, senderID: currentUser.uid, senderEmail: currentUser.email!, timeStamp: self.getTimestamp(), dbReferenceDocumentId: "")
                        newMessage.imageWidth = selectedImage.size.width.description
                        newMessage.imageHeight = selectedImage.size.height.description
                        DatabaseManager.postMessage(message: newMessage, messageBoard: self.messageBoard)
                    }
                })
            }
        
            
            if isImageFromCamera && saveImageFromCamera {
                UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save error", message: error.localizedDescription)
        } else {
            showAlert(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
}
