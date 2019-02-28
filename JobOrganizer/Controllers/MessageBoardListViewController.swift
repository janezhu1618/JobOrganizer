//
//  MessageBoardListViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase

class MessageBoardListViewController: UIViewController {

    @IBOutlet weak var messageBoardListTableView: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    private var listener: ListenerRegistration!
    private var messageBoardListArray: [MessageBoard] = [/*MessageBoard.init(name: "Interview Tips", description: "What to do before, during, and after an interview.", creatorID: "", lastUpdated: "", dbReferenceDocumentId: "")*/]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBoardListTableView.dataSource = self
        retrieveMessageBoards()
    }
    
    private func checkForEmptyState() {
        messageBoardListTableView.backgroundView = messageBoardListArray.isEmpty ? emptyStateView : nil
    }
    
    private func retrieveMessageBoards() {
        messageBoardListArray.removeAll()
        listener = DatabaseManager.firebaseDB.collection(DatabaseKeys.MessagesCollectionKey).addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                var messageBoards = [MessageBoard]()
                for messageBoard in snapshot.documents {
                    let messageBoardToAdd = MessageBoard(dict: messageBoard.data() as! [String : String])
                    messageBoards.append(messageBoardToAdd)
                }
                self.messageBoardListArray = messageBoards
                self.checkForEmptyState()
                self.messageBoardListTableView.reloadData()
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? MessageBoardDetailoViewController, let indexPath = messageBoardListTableView.indexPathForSelectedRow else { print("error in segueing to message board")
            return }
        destination.messageBoard = messageBoardListArray[indexPath.row]
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a new message board", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Message Board Title"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Description"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            guard let titleText = alert.textFields!.first!.text,
                let descriptionText = alert.textFields!.last!.text,
                let currentUser = Auth.auth().currentUser else { return }
            //TODO: handle keyboard
            let messageBoardToAdd = MessageBoard(name: titleText, description: descriptionText, creatorID: currentUser.uid, lastUpdated: self.getTimestamp(), dbReferenceDocumentId: "")
            DatabaseManager.addMessageBoard(messageBoard: messageBoardToAdd)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension MessageBoardListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageBoardListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageBoardListTableView.dequeueReusableCell(withIdentifier: "MessageBoardCell", for: indexPath)
        let messageBoard = messageBoardListArray[indexPath.row]
        cell.textLabel?.text = messageBoard.title
        cell.detailTextLabel?.text = messageBoard.description
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let destination = MessageBoardDetailoViewController()
//        destination.messageBoard = messageBoardListArray[indexPath.row]
//        performSegue(withIdentifier: "goToMessageBoard", sender: self)
//    }
    
}
