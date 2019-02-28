//
//  StorageManager.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/28/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation
import FirebaseStorage
import SVProgressHUD

final class StorageManager {

    private init () { }
    
    static let metadata = StorageMetadata()
    
    static func uploadMessageImage(_ data: Data, toMessage message: Message, inMessageBoard messageBoard: MessageBoard) {
        let imageReference = Storage.storage().reference().child(StorageKeys.MessageImages).child("\(message.dbReferenceDocumentId).jpg")
        metadata.contentType = "image/jpeg"
        imageReference.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                print("error uploading data")
                return
            }
            let _ = metadata.size
            imageReference.downloadURL(completion: { (url, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).collection(DatabaseKeys.MessagesCollectionKey).document(message.dbReferenceDocumentId).updateData([ MessageDictionaryKeys.imageURL : url!], completion: { (error) in
                        if let error = error {
                            print("error updating imageURL: \(error)")
                        } else {
                            print("\(message.messageBody) imageURL updated")
                        }
                    })
                    SVProgressHUD.showSuccess(withStatus: "Image added")
                }
            })
        }
    }
    
    static func uploadProfileImage(_ data: Data) {
        guard let currentUser = DatabaseManager.getCurrentUser() else {
            print("no current user")
            return
        }
        let imageReference = Storage.storage().reference().child(StorageKeys.ProfileImages).child("\(currentUser.uid).jpg")
        metadata.contentType = "image/jpeg"
        /*let uploadTask = */
        imageReference.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                print("error uploading data")
                return
            }
            let _ = metadata.size
            imageReference.downloadURL(completion: { (url, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                   DatabaseManager.updateUser(currentUser: currentUser, photoURL: url)
                    SVProgressHUD.showSuccess(withStatus: "Image uploaded")
                }
            })
        }
//        uploadTask.observe(.failure) { (storageTaskSnapshot) in
//            print("failure...")
//        }
//        uploadTask.observe(.pause) { (storageTaskSnapshot) in
//            print("pause...")
//        }
//        uploadTask.observe(.progress) { (storageTaskSnapshot) in
//            print("progress...")
//        }
//        uploadTask.observe(.resume) { (storageTaskSnapshot) in
//            print("resume...")
//        }
//        uploadTask.observe(.success) { (storageTaskSnapshot) in
//            print("success...")
//        }
    }
}
