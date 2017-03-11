//
//  Post.swift
//  photoSharing
//
//  Created by HOISIO LONG on 10/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post: PFObject, PFSubclassing {
    
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var image: Observable<UIImage?> = Observable(nil)
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    var photoUploadTask: UIBackgroundTaskIdentifier?
    //MARK: PFSubclassing Protocol

    static func parseClassName() -> String {
        return "Post"
    }
    
    override init () {
        super.init()
    }
    
//    override class func initialize() {
////        var onceToken : dispatch_once_t = 0;
////        dispatch_once(&onceToken) {
////            // inform Parse about this subclass
////            self.registerSubclass()
////        }
//
//    }
    
    func uploadPost() {
        if let image = image.value {
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let imageFile = PFFile(data: imageData!)
            
            //add background task
            photoUploadTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { 
                UIApplication.shared.endBackgroundTask(self.photoUploadTask!)
            })
            
            imageFile?.saveInBackground(block: { (success:Bool, error:Error?) in
                UIApplication.shared.endBackgroundTask(self.photoUploadTask!)
                print("save image to server")
            })
            
            //post data with user upload to server
            user = PFUser.current()
            self.imageFile = imageFile
            saveInBackground(block: { (success, error) in
                print("save post to server")
            })
            
        }
    }
    
    func imageDownload() {
        
        if image.value == nil {
            imageFile?.getDataInBackground(block: { (data:Data?, error:Error?) in
                if let data = data {
                    let image = UIImage(data: data, scale: 1.0)
                    self.image.value = image
                }
            })
        }
        
    }
    
    func fetchLikes() {
        if likes.value == nil {
            
            ParseHelper.likesForPost(post: self, completionBlock: { (results:[PFObject]?, error:Error?) in
                let likes = results?.filter { like in like[ParseHelper.LikeFromUser] != nil }
                
                self.likes.value = likes?.map { like in
                    
                    let fromUser = like[ParseHelper.LikeFromUser] as! PFUser
                    
                    return fromUser
                }
            })
        }
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        
        if doesUserLikePost(user: user) {
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user: user, post: self)
        } else {
            likes.value?.append(user)
            ParseHelper.likePost(user: user, post: self)
        }
    }
    
    
    
    
}
