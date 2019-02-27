//
//  MessageCell.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    
    @IBOutlet weak var messageBackground: UIView!
    
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageSender: UILabel!
    @IBOutlet weak var messageUserProfilePicture: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
