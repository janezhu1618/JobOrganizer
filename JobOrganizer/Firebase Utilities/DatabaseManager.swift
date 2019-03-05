//
//  DatabaseManager.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import SVProgressHUD

final class DatabaseManager {
    private init () { }
    static let usersession = (UIApplication.shared.delegate as! AppDelegate).usersession
    
    static let firebaseDB: Firestore = {
        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        return db
    }()
    
    static func updateMessageBoardInfo(messageBoard: MessageBoard, newInfo: String, editKey: String) {
 firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).updateData([editKey : newInfo]) { (error) in
            if let error = error {
                print("error updating messageboard for \(editKey): \(error)")
            } else {
                print("field updated for \(editKey)")
            }
        }
    }
    
    static func addMessageBoard(messageBoard: MessageBoard) {
        var ref: DocumentReference? = nil
        let messageBoard: [String : String] = [MessageBoardKeys.title : messageBoard.title,
                                               MessageBoardKeys.description : messageBoard.description,
                                               MessageBoardKeys.lastUpdated : messageBoard.lastUpdated,
                                               MessageBoardKeys.creatorID : messageBoard.creatorID]
        ref = firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).addDocument(data: messageBoard, completion: { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Message Board Created")
                DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(ref!.documentID).updateData(["dbReferenceDocumentId" : ref!.documentID ], completion: { (error) in
                    if let error = error {
                        print("error updating field: \(error)")
                    } else {
                        print("field updated")
                    }
                })
            }
        })
    }
    
    static func postMessage(message: Message, messageBoard: MessageBoard) {
        var ref: DocumentReference? = nil
        let messageToPost: [String : String] = [MessageDictionaryKeys.messageBody : message.messageBody,
                                        MessageDictionaryKeys.senderEmail : message.senderEmail,
                                        MessageDictionaryKeys.senderID : message.senderID,
                                        MessageDictionaryKeys.timeStamp : message.timeStamp, MessageDictionaryKeys.imageURL : message.imageURL]
        ref = firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).collection(DatabaseKeys.MessagesCollectionKey).addDocument(data: messageToPost) { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            } else {

                SVProgressHUD.showSuccess(withStatus: "Message Posted")
                DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).collection(DatabaseKeys.MessagesCollectionKey).document(ref!.documentID).updateData([DatabaseKeys.dbReferenceDocumentID : ref!.documentID], completion: { (error) in
                    if let error = error {
                        print("error updating docID: \(error)")
                    } else {
                        print("\(messageBoard.title) docID updated")
                    }
                    })
                DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).document(messageBoard.dbReferenceDocumentId).updateData([MessageBoardKeys.lastUpdated : message.timeStamp], completion: { (error) in
                    if let error = error {
                        print("error updating messageboard timestamp: \(error)")
                    } else {
                        print("messageboard \(messageBoard.title) timestamp updated")
                    }
                })
            }
        }
    }
    
    static func updateJob(newInfo: String, jobKey: String, jobID: String) {
        guard let currentUser = usersession?.getCurrentUser() else { return }

        firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).document(jobID).updateData([jobKey: newInfo], completion: { (error) in
            if let error = error {
                print("error updating jobInfo for \(jobKey): \(error)")
            } else {
                print("field updated for \(jobKey)")
            }
        })
    }
    
    static func postJob(job: Job) {
        guard let currentUser = usersession?.getCurrentUser() else { return }
        var ref: DocumentReference? = nil
        let dataToPost: [String:String] = [JobDictionaryKeys.company : job.company,
                                           JobDictionaryKeys.position : job.position,
                                           JobDictionaryKeys.applicationPhase : job.applicationPhase,
                                         JobDictionaryKeys.jobPostingURL : job.jobPostingURL,
                                         JobDictionaryKeys.notes : job.notes,
                                         JobDictionaryKeys.dateCreated : job.dateCreated,
                                         JobDictionaryKeys.lastUpdated : job.lastUpdated,
                                         JobDictionaryKeys.contactPersonName : job.contactPersonName,
                                         JobDictionaryKeys.contactPersonNumber : job.contactPersonNumber,
                                         JobDictionaryKeys.contactPersonEmail : job.contactPersonEmail,
                                         JobDictionaryKeys.userID : job.userID]
         ref = firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).addDocument(data: dataToPost) { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            } else {
               SVProgressHUD.showSuccess(withStatus: "Job Added")
                firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).document(ref!.documentID).updateData(["dbReferenceDocumentId" : ref!.documentID ], completion: { (error) in
                    if let error = error {
                        print("error updating field: \(error)")
                    } else {
                        print("field updated")
                    }
                })
            }
        }
    }
    
    
    static func updateUser(currentUser: User, photoURL: URL?) {
        let request = currentUser.createProfileChangeRequest()
        request.photoURL = photoURL
        request.commitChanges { (error) in
            if let error = error {
                print("error: \(error)")
            } else {
                guard let photoURL = photoURL else {
                    print("no photoURL")
                    return
                }
                DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).updateData(["imageURL" : photoURL.absoluteString], completion: { (error) in
                    if let error = error {
                        print("updating photo url error: \(error.localizedDescription)")
                    } else {
                        print("successfully")
                    }
                })
            }
        }
    }
}

