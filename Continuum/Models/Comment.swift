//
//  Comment.swift
//  Continuum
//
//  Created by Jimmy on 5/14/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

struct CommentStrings {
    static let recordTypeKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postKey = "post"
    static let PostReferenceKey = "postReference"
}

class Comment {
    let text: String
    let timestamp: Date
    let recordID: CKRecord.ID
    var post: Post?
    
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), post: Post?) {
        self.text = text
        self.timestamp = timestamp
        self.recordID = recordID
        self.post = post
    }
    
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
            let timestamp = ckRecord[CommentStrings.timestampKey] as? Date else { return nil }
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, post: post)
    }
} // End of Class

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm)
    }
}

extension CKRecord {
    
    convenience init(comment: Comment) {
        
        self.init(recordType: CommentStrings.recordTypeKey, recordID: comment.recordID)
        
        self.setValuesForKeys([
            CommentStrings.textKey : comment.text,
            CommentStrings.timestampKey : comment.timestamp,
            CommentStrings.PostReferenceKey : comment.postReference
        ])
    }
}
