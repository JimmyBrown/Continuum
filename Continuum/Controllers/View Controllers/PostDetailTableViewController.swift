//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Jimmy on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var followPostButtonTapped: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Actions
    
    @IBAction func commentButtonClicked(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add Comment", message: "Well add a comment", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Comment here..."
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let commentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let comment = alertController.textFields?.first?.text, !comment.isEmpty,
                let post = self.post else { return }
            
            PostController.sharedInstance.addComment(text: comment, post: post, completion: { (comment) in
                
            })
            
            self.tableView.reloadData()
        }
        
        alertController.addAction(commentAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        guard let comment = post?.caption, let photo = post?.photo else { return }
        let shareView = UIActivityViewController(activityItems: [comment, photo], applicationActivities: nil)
        present(shareView, animated: true, completion: nil)
    }
    
    @IBAction func followPostButtonClicked(_ sender: Any) {
        guard let post = post else { return }
        
        PostController.sharedInstance.checkSubscription(for: post) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.updateFollowPostButtonText()
                }
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    func updateFollowPostButtonText() {
        guard let post = post else { return }
        
        PostController.sharedInstance.toggleSubscription(for: post) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let found):
                    let followPostButtonText = found ? "Unfollow Post" : "Follow Post"
                    self.followPostButtonTapped.setTitle(followPostButtonText, for: .normal)
                case .failure(let error):
                    print(error.errorDescription)
                }
            }
        }
    }
    
    func updateViews() {
        guard let post = post else { return }
        photoImageView.image = post.photo
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post else { return }
        PostController.sharedInstance.fetchComments(post: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timestamp.stringWith(dateStyle: .medium, timeStyle: .short)
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
