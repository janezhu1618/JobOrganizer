//
//  JobListViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/25/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase

class JobListViewController: UIViewController {

    @IBOutlet weak var jobSearchBar: UISearchBar!
    @IBOutlet weak var jobTableView: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    private var jobsArray = [Job]()
    private let jobsDatabase = Database.database().reference().child("Jobs")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobTableView.dataSource = self
        jobTableView.delegate = self
        jobSearchBar.delegate = self
        retrieveJobs()
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("add button pressed")
        
    }
    
    private func checkForEmptyState() {
        jobTableView.backgroundView = jobsArray.isEmpty ? emptyStateView : nil
//        if jobsArray.isEmpty {
//            jobTableView.backgroundView = emptyStateView
//        } else {
//            jobTableView.backgroundView = nil
//        }
    }
    
    private func retrieveJobs() {
        jobsDatabase.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let job = Job.init(company: snapshotValue[JobDictionaryKeys.company]!,
                               position: snapshotValue[JobDictionaryKeys.position]!,
                               jobPostingURL: snapshotValue[JobDictionaryKeys.jobPostingURL]!,
                               notes: snapshotValue[JobDictionaryKeys.notes]!,
                               applicationPhase: snapshotValue[JobDictionaryKeys.applicationPhase]!,
                               dateCreated: snapshotValue[JobDictionaryKeys.dateCreated]!,
                               lastUpdated: snapshotValue[JobDictionaryKeys.lastUpdated]!,
                               contactPersonName: snapshotValue[JobDictionaryKeys.contactPersonName]!,
                               contactPersonNumber: snapshotValue[JobDictionaryKeys.contactPersonNumber]!,
                               contactPersonEmail: snapshotValue[JobDictionaryKeys.contactPersonEmail]!,
                               userID: snapshotValue[JobDictionaryKeys.userID]!)
            self.jobsArray.append(job)
            self.checkForEmptyState()
            self.jobTableView.reloadData()
        }
    }
    
}

extension JobListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = jobTableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
        let job = jobsArray[indexPath.row]
        cell.textLabel?.text = job.company
        cell.detailTextLabel?.text = job.applicationPhase
        cell.imageView?.image = UIImage(named: "jobImage")
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobsArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) selected")
    }
}

extension JobListViewController: UISearchBarDelegate {
    //
}
