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
    private var messageBoardListArray: [MessageBoard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBoardListTableView.dataSource = self
        messageBoardListTableView.delegate = self
        retrieveMessageBoards()
    }
    
    private func checkForEmptyState() {
        messageBoardListTableView.backgroundView = messageBoardListArray.isEmpty ? emptyStateView : nil
        messageBoardListTableView.separatorStyle = messageBoardListArray.isEmpty ? .none : .singleLine
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
                messageBoards.sort{ $0.lastUpdated > $1.lastUpdated }
                self.messageBoardListArray = messageBoards
                self.checkForEmptyState()
                self.messageBoardListTableView.reloadData()
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? MessageBoardDetailViewController, let indexPath = messageBoardListTableView.indexPathForSelectedRow else {
            return }
        destination.messageBoard = messageBoardListArray[indexPath.row]
    }

}

extension MessageBoardListViewController: UITableViewDataSource, UITableViewDelegate {
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
}
