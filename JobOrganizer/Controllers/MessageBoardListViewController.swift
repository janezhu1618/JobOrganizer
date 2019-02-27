//
//  MessageBoardListViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit

class MessageBoardListViewController: UIViewController {

    @IBOutlet weak var messageBoardListTableView: UITableView!
    
    private var messageBoardListArray: [MessageBoard] = [MessageBoard.init(name: "Interview Tips", description: "What to do before, during, and after an interview.")]
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBoardListTableView.dataSource = self
        //messageBoardListTableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? MessageBoardDetailoViewController, let indexPath = messageBoardListTableView.indexPathForSelectedRow else { print("error in segueing to message board")
            return }
        destination.messageBoard = messageBoardListArray[indexPath.row]
    }

}

extension MessageBoardListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageBoardListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageBoardListTableView.dequeueReusableCell(withIdentifier: "MessageBoardCell", for: indexPath)
        let messageBoard = messageBoardListArray[indexPath.row]
        cell.textLabel?.text = messageBoard.name
        cell.detailTextLabel?.text = messageBoard.description
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let destination = MessageBoardDetailoViewController()
//        destination.messageBoard = messageBoardListArray[indexPath.row]
//        performSegue(withIdentifier: "goToMessageBoard", sender: self)
//    }
    
}
