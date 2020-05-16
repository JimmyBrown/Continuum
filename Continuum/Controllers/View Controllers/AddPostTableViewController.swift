//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Jimmy on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    // MARK: - Properties
    var selectImage: UIImage?
    
    // MARK: - Outlets
    @IBOutlet weak var captionTextField: UITextField!

    
    // MARK: - Actions
    @IBAction func addPostTapped(_ sender: Any) {
        
        guard let postImage = selectImage, let caption = captionTextField.text else { return }
        
        PostController.sharedInstance.createPostWith(image: postImage, caption: caption) { (post) in
            
        }
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captionTextField.text = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelectorVC" {
            let photoSelector = segue.destination as? PhotoSelectorViewController
            photoSelector?.delegate = self
        }
    }
}

extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func PhotoSelectorViewControllerSelected(image: UIImage) {
        selectImage = image
    }
}


