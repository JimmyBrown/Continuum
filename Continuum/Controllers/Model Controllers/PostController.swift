//
//  PostController.swift
//  Continuum
//
//  Created by Jimmy on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import CloudKit
import UIKit

class PostController {
    
    // MARK: - Properties
    static let sharedInstance = PostController()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    private init() {
        subscribeToNewPosts { (result) in
            switch result {
            case .success(_):
                print("Successfully set a new subscription")
                return
            case .failure(_):
                print("Wasn't able to set a new subscription")
                print("Couldn't delete subscription \(#file) >> \(#function) >> \(#line)")
                return
            }
        }
    }
    
    var posts: [Post] = []
    
    // MARK: - CRUD
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        
        let record = CKRecord(comment: comment)
        
        publicDB.save(record) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let comment = Comment(ckRecord: record, post: post)
                else { return completion(.failure(.noRecord)) }
            print("Added comment successfully")
            completion(.success(comment))
        }
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void) {
        let post = Post(caption: caption, photo: image)
        posts.append(post)
        
        let record = CKRecord(post:post)
        
        publicDB.save(record) { (record, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let post = Post(ckRecord: record) else { return completion(.failure(.noPost)) }
            
            completion(.success(post))
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[Post]?, PostError>) -> Void) {
        
        let fetchPostsPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PostStrings.typeKey, predicate: fetchPostsPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            print("Fetched posts successfully")
            let posts = records.compactMap({ Post(ckRecord: $0) })
            self.posts = posts
            completion(.success(posts))
        }
    }
    
    func fetchComments(post: Post, completion: @escaping (Result<[Comment]?, PostError>) -> Void) {
        
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.PostReferenceKey, postReference)
        let commentIDs = post.comments.compactMap({ $0.recordID })
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in (#function) : (error.localizedDescription) \n---\n (error)")
                completion(.failure(.ckError(error)))
                return
            }
            
            guard let records = records else { completion(.failure(.noRecord)); return }
            let comments = records.compactMap{ Comment(ckRecord: $0, post: post) }
            post.comments.append(contentsOf: comments)
            completion(.success(comments))
        }
    }
    
    // Subscriptions Methods
    func subscribeToNewPosts(completion: @escaping (Result<Bool, PostError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: PostStrings.typeKey, predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New post added"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("Error in \(#file) >> \(#function) >> \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            print("Successfully subscribed to post")
            return completion(.success(true))
        }
    }
    
    func addSubscriptionTo(for post: Post, completion: @escaping (Result<Bool, PostError>) -> Void) {
        
        let postRecordID = post.recordID
        
        let predicate = NSPredicate(format: "%K = %@", CommentStrings.PostReferenceKey, postRecordID)
        
        let subscription = CKQuerySubscription(recordType: PostStrings.commentsKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "New Comment"
        notificationInfo.alertBody = "A new comment added to a post you follow"
        notificationInfo.soundName = "default"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = true
        notificationInfo.desiredKeys = [CommentStrings.textKey, CommentStrings.timestampKey]
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            
            if let error = error {
                print("Error in \(#file) >> \(#function) >> \(#line) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            print("Subscription add")
            return completion(.success(true))
        }
    }
    
    func removeSubscriptionTo(for post: Post, completion: @escaping (Result<Bool, PostError>) -> Void) {
        
        let subscriptionID = post.recordID.recordName
        
        publicDB.delete(withSubscriptionID: subscriptionID) { (_, error) in
            
            if let error = error {
                print("Error in \(#file) >> \(#function) >> \(#line) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            print("Subscription deleted")
            return completion(.success(true))
        }
    }
    
    func checkSubscription(for post: Post, completion: ((@escaping (Result<Bool, PostError>) -> Void))) {
        
        let subscriptionID = post.recordID.recordName
        
        publicDB.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            
            if let error = error {
                print("Error in \(#file) >> \(#function) >> \(#line) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            if subscription != nil {
                print("Subscription found")
                return completion(.success(true))
            } else {
                print("Subscription not found \(#file) >> \(#function) >> \(#line)")
                return completion(.failure(.couldNotDeleteSubscription))
            }
        }
    }
    
    func toggleSubscription(for post: Post, completion: @escaping (Result<Bool, PostError>) -> Void) {
        
        checkSubscription(for: post) { (result) in
            
            switch result {
            case .success(_):
                self.removeSubscriptionTo(for: post, completion: { (result) in
                    switch result {
                    case .success(_):
                        print("Successfully removed the subscription to the post with caption: \(post.caption)")
                        return completion(.success(true))
                    case .failure(_):
                        print("There was an error removing the subscription to the post with caption: \(post.caption)")
                        print("Couldn't delete subscription \(#file) >> \(#function) >> \(#line)")
                        return completion(.failure(.couldNotDeleteSubscription))
                    }
                })
            case .failure(_):
                self.addSubscriptionTo(for: post, completion: { (result) in
                    switch result {
                    case .success(_):
                        print("Successfully added subscription: \(post.caption)")
                        return completion(.success(true))
                    case .failure(_):
                        print("Couldn't successfully: \(post.caption)")
                        print("Couldn't delete subscription \(#file) >> \(#function) >> \(#line)")
                        return completion(.failure(.couldNotDeleteSubscription))
                    }
                })
            }
        }
    }

} // End of Class
