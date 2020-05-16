//
//  Post.swift
//  Continuum
//
//  Created by Jimmy on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import CloudKit
import UIKit

struct PostStrings {
    static let typeKey = "Post"
    static let captionKey = "caption"
    static let timestampKey = "timestamp"
    static let commentsKey = "comments"
    static let photoKey = "photo"
    static let commentCountKey = "commentCount"
}

class Post {
    
    var photoData: Data?
    var timestamp: Date
    var caption: String
    var comments: [Comment]
    var recordID: CKRecord.ID
    var commentCount: Int
    
    var photo: UIImage?{
        get{
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set{
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(timestamp: Date = Date(), caption: String, comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0, photo: UIImage?) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.recordID = recordID
        self.commentCount = commentCount
        self.photo = photo
    }
    
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
} // End of Class

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            for comment in comments {
                if comment.matches(searchTerm: searchTerm) {
                    return true
                }
            }
        }
        return false
    }
}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostStrings.typeKey, recordID: post.recordID)
        self.setValue(post.caption, forKey: PostStrings.captionKey)
        self.setValue(post.timestamp, forKey: PostStrings.timestampKey)
        self.setValue(post.commentCount, forKey: PostStrings.commentCountKey)
        
        if let postPhoto = post.imageAsset {
            self.setValue(postPhoto, forKey: PostStrings.photoKey)
        }
    }
}
// MARK: - Post Convenience init
extension Post {
    convenience init?(ckRecord: CKRecord) {
        guard let caption = ckRecord[PostStrings.captionKey] as? String,
            let timestamp = ckRecord[PostStrings.timestampKey] as? Date,
            let commentCount = ckRecord[PostStrings.commentCountKey] as? Int
            else { return nil }
        
        
        
        var postPhoto: UIImage?
        
        if let photoAsset = ckRecord[PostStrings.photoKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL)
                postPhoto = UIImage(data: data)
            } catch {
                print(error)
                print(error.localizedDescription)
            }
        }
        self.init(timestamp: timestamp, caption: caption, comments: [], recordID: ckRecord.recordID, commentCount: commentCount, photo: postPhoto)
    }
    
}

