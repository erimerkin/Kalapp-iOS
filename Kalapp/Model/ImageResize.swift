//
//  ImageResize.swift
//  Kalapp
//
//  Created by Erkin Doğan on 15.04.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit

class ImageResize {
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        
        
        let newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeProfilePhoto(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heigthRatio = targetSize.height / size.height
        
        var newSize : CGSize
        
        if widthRatio > heigthRatio {
            newSize = CGSize(width: size.width * heigthRatio, height: size.height * heigthRatio)
        }
        else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x:0, y:0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
}
