//
//  ViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/6/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let ref = Database.database().reference()
//       // ref.child("someID/name").setValue("ace")
//        //changing value of a key to something else
//
//        //generate random key
//        ref.childByAutoId().setValue(["name" : "Tom", "age" : 18, "location" : "los angeles, ca"])
//
//        //retrieving
//        ref.child("someid").observeSingleEvent(of: .value) { (snapshot) in
////            let username = snapshot.value as? [String : Any]
////        }
//
//        //updating data
//    ref.child("someID/name").setValue("Lux")
//        ref.child("LY3hYY5Hu3B0rzUNxhE/age").setValue(12)
//
//        //updating an array of dictionaries
//        let updates = ["someID/name" : "Garen", "LY3hYY5Hu3B0rzUNxhE/name" : "nunu"]
//        ref.updateChildValues(updates)
//
//        //deleting data
//        ref.child("LY3hYY5Hu3B0rzUNxhE").removeValue()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

