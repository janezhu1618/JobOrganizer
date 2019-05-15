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
import Toucan

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var saveCameraImageButton: UISwitch!
    @IBOutlet weak var profileImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileUserStatistics: UILabel!
    @IBOutlet weak var profileUserEmail: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    
    private var usersession: UserSession = (UIApplication.shared.delegate as! AppDelegate).usersession
    private var imagePickerViewController: UIImagePickerController!
    private var isImageFromCamera: Bool = false
    private var saveImageFromCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerViewController = UIImagePickerController()
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.delegate = self
        setupRoundProfileImage()
        profileImageActivityIndicator.hidesWhenStopped = true
        setupSaveImageSetting()
        getUserInfoAndProfileImage()
        setStatistics()
    }
    
    private func setStatistics() {
        let statisticsArr = Statistics.getStatistics()
        profileUserStatistics.text = "Statistics\nApplication Sent: \(statisticsArr[0]) \nPhone Interview: \(statisticsArr[1]) \nIn-Person Interview: \(statisticsArr[2]) \nWhiteboarding: \(statisticsArr[3]) \nJob Offer: \(statisticsArr[4])"
    }
    
    private func getUserInfoAndProfileImage() {
        if let currentUser = usersession.getCurrentUser() {
            profileUserEmail.text = currentUser.email
            if let photoURL = currentUser.photoURL {
                profileImageActivityIndicator.startAnimating()
                profileImageButton.kf.setImage(with: photoURL, for: .normal)
                profileImageActivityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupSaveImageSetting() {
        if let saveImageSettingOn = UserDefaults.standard.object(forKey: UserDefaultsKeys.saveCameraImage) as? Bool {
            if saveImageSettingOn {
                saveImageFromCamera = true
                saveCameraImageButton.setOn(true, animated: false)
            } else {
                saveImageFromCamera = false
                saveCameraImageButton.setOn(false, animated: false)
            }
        } 
    }
    
    
    fileprivate func setupRoundProfileImage() {
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

    @IBAction func saveCameraPhotoSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.saveCameraImage)
            saveImageFromCamera = true
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.saveCameraImage)
            saveImageFromCamera = false
        }
    }
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
            
        }
        
        if var selectedImage = selectedImageFromPicker {
            if isImageFromCamera && saveImageFromCamera {
                UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
            selectedImage = Toucan(image: selectedImage).resize(CGSize(width: 150, height: 150)).image!
            profileImageButton.setImage(selectedImage, for: .normal)
            guard let data = selectedImage.jpegData(compressionQuality: 1) else { print("unable to convert selected image to image data")
                return
            }
            StorageManager.uploadProfileImage(data)
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
