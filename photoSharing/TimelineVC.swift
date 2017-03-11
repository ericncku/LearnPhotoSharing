//
//  TimelineVC.swift
//  photoSharing
//
//  Created by HOISIO LONG on 9/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineVC: UIViewController, UITabBarControllerDelegate, UITableViewDataSource, TimelineComponentTarget, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    var posts:[Post] = []
    
    var timelineComponent: TimelineComponent<Post, TableView>!
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set timelineVC is the delegate of tabBarController
        self.tabBarController?.delegate = self
        
        //use timelinecomponent
        timelineComponent = TimelineComponent(target: self)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if (viewController is PhotoVC) {
            takePhoto()
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineComponent.content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = timelineComponent.content[indexPath.row]
        post.imageDownload()
        post.fetchLikes()
        cell.post = post
        
//        cell.postImg.image = posts[indexPath.row].image.value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
    func takePhoto() {
        
        //instantiate photo taking class, provide callback when photo selected, then upload image to server
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, callback: { (image: UIImage?) in
            if let img = image {
                print("success catch image")
                
                //upload image and post to server
                let post = Post()
                post.image.value = img
                post.uploadPost()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //fetch posts from server
//        ParseHelper.timelineRequestForCurrentUser { (result: [PFObject]?, erro:Error?) in
//            self.posts = result as? [Post] ?? []
//            
//            //after finish download all of the post and data, reload tableview
//            self.tableView.reloadData()
//        }
        timelineComponent.loadInitialIfRequired()
    }
    
    func loadInRange(range: CountableRange<Int>, completionBlock: @escaping ([Post]?) -> ()) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range: range) { (result:[PFObject]?, error:Error?) in
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }
    
}
