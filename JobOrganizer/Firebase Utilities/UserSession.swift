//
//  UserSession.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/28/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation
import Firebase

final class UserSession {
    public func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
