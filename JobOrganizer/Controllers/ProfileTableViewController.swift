//
//  ProfileTableViewController.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/26/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Kingfisher

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileUserStatistics: UILabel!
    @IBOutlet weak var profileUserEmail: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    private let currentUser = Auth.auth().currentUser
    private var imagePickerViewController: UIImagePickerController!
    private var isImageFromCamera: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        profileUserEmail.text = currentUser?.email
        setupProfileImageButton()
        profileImageActivityIndicator.hidesWhenStopped = true
        if let currentUser = currentUser {
            if let photoURL = currentUser.photoURL {
                profileImageActivityIndicator.startAnimating()
                profileImageButton.kf.setImage(with: photoURL, for: .normal)
                profileImageActivityIndicator.stopAnimating()
            }
            
        }
    }
    
    fileprivate func setupProfileImageButton() {
        profileImageButton.layer.cornerRadius = profileImageButton.bounds.width / 2.0
        profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
        profileImageButton.layer.borderWidth = 0.5
        profileImageButton.clipsToBounds = true
    }
    
    @IBAction func profileImageTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Profile Image", message: "What would like like to do?", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.imagePickerViewController.sourceType = .camera
                self.isImageFromCamera = true
                self.showImagePickerViewController()
            }))
        }
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.imagePickerViewController.sourceType = .photoLibrary
            self.isImageFromCamera = false
            self.showImagePickerViewController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "goToSignInPage", sender: self)
        } catch {
            print("there was a problem signing out: \(error)")
        }
    }

    private func showImagePickerViewController() {
        present(imagePickerViewController, animated: true, completion: nil)
    }
    //help source with saving photo from camera https://stackoverflow.com/questions/40854886/swift-take-a-photo-and-save-to-photo-library

}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageButton.setImage(image, for: .normal)
            guard let data = image.jpegData(compressionQuality: 1) else { print("unable to convert image to image data")
                return
            }
            StorageManager.uploadProfileImage(data)
            if isImageFromCamera {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } else {
            print("original image is nil")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save error", message: error.localizedDescription)
        } else {
            showAlert(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
}
