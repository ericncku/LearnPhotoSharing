//
//  File.swift
//  photoSharing
//
//  Created by HOISIO LONG on 9/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = (UIImage?) -> ()

class PhotoTakingHelper: NSObject {
    
    //View controller on which AlertViewController and UIImagePickerController are presented
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: @escaping PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        showPhotoSourceSelection()
        
    }
    
    // show photo source alert controller
    func showPhotoSourceSelection() {
        
        //Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        
        //add cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        //add photo library action
        let photoLibraryAction = UIAlertAction(title: "Photo From Library", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        //add camer action
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            let cameraAction = UIAlertAction(title: "Photo From Camera", style: .default, handler: { (action) in
                self.showImagePickerController(sourceType: .camera)
            })
            alertController.addAction(cameraAction)
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    //show imagePicker controller
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        self.viewController.present(imagePickerController!, animated: true, completion: nil)
        
    }
    
}

//extense the function of PhotoTakingHelper class , 1.didFinishPicking, 2.didCancel
extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        viewController.dismiss(animated: false, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            callback(image)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated: false, completion: nil)
    }
}

