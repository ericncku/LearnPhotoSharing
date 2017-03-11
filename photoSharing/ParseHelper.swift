//
//  ParseHelper.swift
//  photoSharing
//
//  Created by HOISIO LONG on 10/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import Foundation
import Parse

typealias completedParseBlock = ([PFObject]?, Error?) -> ()

class ParseHelper: PFObject {
    
    // Following Relation
    static let FollowClass       = "Follow"
    static let FollowFromUser    = "fromUser"
    static let FollowToUser      = "toUser"
    
    // Like Relation
    static let LikeClass         = "Like"
    static let LikeToPost        = "toPost"
    static let LikeFromUser      = "fromUser"
    
    // Post Relation
    static let PostUser          = "user"
    static let PostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let FlaggedContentClass    = "FlaggedContent"
    static let FlaggedContentFromUser = "fromUser"
    static let FlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    // MARK: Timeline
    static func timelineRequestForCurrentUser(range: CountableRange<Int>, completionBlock: @escaping completedParseBlock) {
        //fetch posts from server
        let followingQuery = PFQuery(className: FollowClass)
        followingQuery.whereKey(FollowFromUser, equalTo: PFUser.current()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(PostUser, matchesKey: FollowToUser, in: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser?.whereKey(PostUser, equalTo: PFUser.current()!)
        
        let query = PFQuery.orQuery(withSubqueries: [postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(PostUser)
        query.order(byDescending: "createdAt")
        
        //add pagation
        query.skip = range.startIndex
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackground(block: completionBlock)
    }
    
    // MARK: Likes
    static func likePost(_ user: PFUser, post: Post) {
        let likeObject = PFObject(className: LikeClass)
        likeObject[LikeFromUser] = user
        likeObject[LikeToPost] = post
        likeObject.saveInBackground(block: nil)
        
    }
    
    static func unlikePost(_ user: PFUser, post: Post) {
        //step1: fetch from user to find the user is like it or not
        let query = PFQuery(className: LikeClass)
        query.whereKey(LikeFromUser, equalTo: user)
        query.whereKey(LikeToPost, equalTo: post)
        query.findObjectsInBackground { (results:[PFObject]?, erro:Error?) in
            if let results = results as [PFObject]? {
                for result in results {
                    result.deleteInBackground(block: nil)
                }
            }
        }
    }
    
    static func likesForPost(_ post: Post, completionBlock: @escaping completedParseBlock) {
        let query = PFQuery(className: LikeClass)
        query.whereKey(LikeToPost, equalTo: post)
        query.includeKey(LikeFromUser)
        query.findObjectsInBackground(block: completionBlock)
    }
    
    //MARK: add equal objectId return true
    open override func isEqual(_ object: Any?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
    
    
    
}
