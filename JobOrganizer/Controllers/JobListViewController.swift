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
    private var applicationSent = 0
    private var phoneInterview = 0
    private var inPersonInterview = 0
    private var whiteboarding = 0
    private var jobOffer = 0
    private var statistics: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobTableView.dataSource = self
        jobTableView.delegate = self
        jobSearchBar.delegate = self
        retrieveJobs()
    }
    
    private func checkForEmptyState() {
        jobTableView.backgroundView = jobsArray.isEmpty ? emptyStateView : nil
    }
    
    private func retrieveJobs() {
        applicationSent = 0
        phoneInterview = 0
        inPersonInterview = 0
        whiteboarding = 0
        jobOffer = 0
        jobsArray.removeAll()
        guard let currentUser = usersession.getCurrentUser() else {
            print("no logged user")
            return }
        listener = DatabaseManager.firebaseDB.collection(DatabaseKeys.UsersCollectionKey).document(currentUser.uid).collection(DatabaseKeys.JobsCollectionKey).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let snapshot = snapshot {
                var jobs = [Job]()
                for document in snapshot.documents {
                    let jobToAdd = Job(dict: document.data() as! [String : String])
                    jobs.append(jobToAdd)
                    self.calculateStatistics(jobToAdd)
                }
    
                switch UserDefaults.standard.object(forKey: UserDefaultsKeys.sortMethod) as? String {
                case "applicationPhase":
                    jobs.sort{ $0.applicationPhase < $1.applicationPhase }
                case "company":
                    jobs.sort{ $0.company > $1.company }
                case "dateCreated":
                    jobs.sort{ $0.dateCreated < $1.dateCreated }
                default:
                    jobs.sort{ $0.lastUpdated > $1.lastUpdated }
                }
                self.jobsArray = jobs
                self.checkForEmptyState()
                self.jobTableView.reloadData()
            }
            self.statistics = [self.applicationSent, self.phoneInterview, self.inPersonInterview, self.whiteboarding, self.jobOffer]
            Statistics.setStatistics(statistics: self.statistics)
        }
    }
    
    private func calculateStatistics(_ job: Job) {
        switch job.applicationPhase {
        case ApplicationPhase.applicationSent.rawValue:
            applicationSent += 1
            break
        case ApplicationPhase.phoneInterview.rawValue:
            applicationSent += 1
            phoneInterview += 1
            break
        case ApplicationPhase.inPersonInterview.rawValue:
            applicationSent += 1
            phoneInterview += 1
            inPersonInterview += 1
            break
        case ApplicationPhase.whiteboarding.rawValue:
            applicationSent += 1
            phoneInterview += 1
            inPersonInterview += 1
            whiteboarding += 1
            break
        case ApplicationPhase.jobOffer.rawValue:
            applicationSent += 1
            phoneInterview += 1
            inPersonInterview += 1
            whiteboarding += 1
            jobOffer += 1
            break
        default:
            break
        }
        
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sort", message: "Choose how to sort jobs results", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Application Status", style: .default, handler: { (action) in
            UserDefaults.standard.set("applicationPhase", forKey: UserDefaultsKeys.sortMethod)
            self.jobsArray.sort{ $0.applicationPhase < $1.applicationPhase}
            self.jobTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Company Name", style: .default, handler: { (action) in
            UserDefaults.standard.set("company", forKey: UserDefaultsKeys.sortMethod)
            self.jobsArray.sort{ $0.company < $1.company }
            self.jobTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Created Date", style: .default, handler: { (action) in
            UserDefaults.standard.set("dateCreated", forKey: UserDefaultsKeys.sortMethod)
            self.jobsArray.sort{ $0.dateCreated < $1.dateCreated }
            self.jobTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Last Updated Date", style: .default, handler: { (action) in
            UserDefaults.standard.set("lastUpdated", forKey: UserDefaultsKeys.sortMethod)
            self.jobsArray.sort{ $0.lastUpdated > $1.lastUpdated }
            self.jobTableView.reloadData()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension JobListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = jobTableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
        let job = jobsArray[indexPath.row]
        cell.textLabel?.text = job.company
        cell.detailTextLabel?.text = job.applicationPhase
        switch job.applicationPhase {
        case ApplicationPhase.interested.rawValue:
            cell.imageView?.image = UIImage(named: "interested")
        case ApplicationPhase.applicationSent.rawValue:
            cell.imageView?.image = UIImage(named: "resume")
        case ApplicationPhase.phoneInterview.rawValue:
            cell.imageView?.image = UIImage(named: "phone")
        case ApplicationPhase.inPersonInterview.rawValue:
            cell.imageView?.image = UIImage(named: "interview")
        case ApplicationPhase.jobOffer.rawValue:
            cell.imageView?.image = UIImage(named: "handshake")
        case ApplicationPhase.whiteboarding.rawValue:
            cell.imageView?.image = UIImage(named: "whiteboard")
        default:
            cell.imageView?.image = UIImage(named: "itsComplicated")
        }
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
