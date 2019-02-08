//
//  JobViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/8/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase

class JobViewController: UIViewController {
    
    
    //private var jobs

    @IBOutlet weak var jobTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = Auth.auth().currentUser {
            title = "\(currentUser.uid)"
        }
        
        
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func addJob(_ sender: UIBarButtonItem) {
        print("add button pressed")
    }
}
