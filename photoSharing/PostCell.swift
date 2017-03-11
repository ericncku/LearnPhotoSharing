//
//  PostCell.swift
//  photoSharing
//
//  Created by HOISIO LONG on 10/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit
import Bond
import Parse
import ReactiveKit

class PostCell: UITableViewCell {

    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeIconImg: UIImageView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    var postDisposable: Disposable?
    var likeDisposable: Disposable?
    
    var post: Post? {
        didSet {
            
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            if let post = post {
                //blind the image of the post to the "postImg" view, observe likes of post
                postDisposable = post.image.bind(to: postImg.reactive.image)
                likeDisposable = post.likes.observeNext(with: { (users:[PFUser]?) in
                    if let users = users {
                        
                        self.likeLbl.text = self.stringFromUserList(userList: users)
                        self.likeBtn.isSelected = users.contains(PFUser.current()!)
                        self.likeIconImg.isHidden = (users.count == 0)
                        
                    } else {
                        
                        self.likeLbl.text = ""
                        self.likeBtn.isSelected = false
                        self.likeIconImg.isHidden = true
                        
                    }
                })
                
            }
        }
    }
    
    @IBAction func likeBtnTap(_ sender: Any) {
        post?.toggleLikePost(PFUser.current()!)
    }
    
    @IBAction func moreBtnTap(_ sender: Any) {
        
    }
    
    // Generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        // 1
        let usernameList = userList.map { user in user.username! }
        // 2
        let commaSeparatedUserList = usernameList.joined(separator: ", ")
        
        return commaSeparatedUserList
    }
}
