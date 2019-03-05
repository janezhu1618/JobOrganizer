//
//  JobListViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/25/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class JobListViewController: UIViewController {

    @IBOutlet weak var jobSearchBar: UISearchBar!
    @IBOutlet weak var jobTableView: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    private var listener: ListenerRegistration!
    private var jobsArray = [Job]()
    private let usersession: UserSession = (UIApplication.shared.delegate as! AppDelegate).usersession
    
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
    }
    
    private func retrieveJobs() {
        jobsArray.removeAll()
        guard let currentUser = usersession.getCurrentUser() else {
            print("no logged user")
            return }
        listener = DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                //self.showAlert(title: "Network Error", message: error.localizedDescription)
            } else if let snapshot = snapshot {
                var jobs = [Job]()
                for document in snapshot.documents {
                    let jobToAdd = Job(dict: document.data() as! [String : String])
                    jobs.append(jobToAdd)
                }
                jobs.sort{ $0.lastUpdated > $1.lastUpdated }
                self.jobsArray = jobs
                self.checkForEmptyState()
                self.jobTableView.reloadData()
            }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destination = storyboard.instantiateViewController(withIdentifier: "JobTableViewController") as! JobTableViewController
        destination.job = jobsArray[indexPath.row]
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let jobToDelete = self.jobsArray[indexPath.row]
        showDeleteActionSheet { (action) in
            self.deleteJob(job: jobToDelete)
        }
    }
    
    private func deleteJob(job: Job) {
        guard let currentUser = self.usersession.getCurrentUser() else {
            print("no logged user")
            return }
        DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).document(job.dbReferenceDocumentId).delete()
    }
}

extension JobListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text else { return }
        jobsArray = jobsArray.filter{ $0.company.lowercased().contains(searchText.lowercased()) }
        checkForEmptyState()
        jobTableView.reloadData()
    }
}
