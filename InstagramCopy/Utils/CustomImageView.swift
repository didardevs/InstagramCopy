//
//  CustomImageView.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/7/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//


import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastImgUrlUsedToLoadImage: String?
    
    func loadImage(with urlString: String) {
        
        // set image to nil
        self.image = nil
        
        // set lastImgUrlUsedToLoadImage
        lastImgUrlUsedToLoadImage = urlString
        
        // check if image exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        // url for image location
        guard let url = URL(string: urlString) else { return }
        
        // fetch contents of URL
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            
            if self.lastImgUrlUsedToLoadImage != url.absoluteString {
                return
            }
            
            // image data
            guard let imageData = data else { return }
            
            // create image using image data
            let photoImage = UIImage(data: imageData)
            
            // set key and value for image cache
            imageCache[url.absoluteString] = photoImage
            
            // set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
            }.resume()
    }
}

