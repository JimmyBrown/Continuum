//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Jimmy on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let post = post else { return }
        photoImage.image = post.photo
        captionLabel.text = post.caption
        commentCountLabel.text = "Comments: \(post.comments.count)"
    }
}
