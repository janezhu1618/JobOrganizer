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
    
    static func uploadMessageImage(_ data: Data, toMessage: Message, toMessageBoard messageBoard: MessageBoard) {
//        let imageName = NSUUID().uuidString
//        let imageReference = Storage.storage().reference().child(StorageKeys.MessageImages).child("\(imageName).jpg")
//        metadata.contentType = "image/jpeg"
//        imageReference.putData(data, metadata: metadata) { (metadata, error) in
//        guard let _ = metadata else {
//                print("error uploading data")
//                return
//        }
//        imageReference.downloadURL(completion: { (url, error) in
//            if error != nil {
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                let returnURL = url!.absoluteString
//
//// DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).collection(DatabaseKeys.MessagesCollectionKey).document(message.dbReferenceDocumentId).updateData([ MessageDictionaryKeys.imageURL : url!], completion: { (error) in
////                        if let error = error {
////                            print("error updating imageURL: \(error)")
////                        } else {
////                            print("\(message.messageBody) imageURL updated")
////                        }
////                    })
//                SVProgressHUD.showSuccess(withStatus: "Image Posted")
//                }
//            })
//        }
    }
    
    static func uploadProfileImage(_ data: Data) {
        let usersession = (UIApplication.shared.delegate as! AppDelegate).usersession
        guard let currentUser = usersession!.getCurrentUser() else {
            print("no current user")
            return
        }
        let imageReference = Storage.storage().reference().child(StorageKeys.ProfileImages).child("\(currentUser.uid).jpg")
        metadata.contentType = "image/jpeg"
        imageReference.putData(data, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                print("error uploading data")
                return
            }
            imageReference.downloadURL(completion: { (url, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                   DatabaseManager.updateUser(currentUser: currentUser, photoURL: url)
                    SVProgressHUD.showSuccess(withStatus: "Image uploaded")
                }
            })
        }
    }
}
