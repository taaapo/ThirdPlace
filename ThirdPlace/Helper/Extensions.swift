//
//  Extensions.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/22.
//

import Foundation
import UIKit

extension UIColor {
    
    func primaryRed() -> UIColor {
        return UIColor(red: 235/255, green: 99/255, blue: 93/255, alpha: 1)
    }
    
    func primaryGray() -> UIColor {
        return UIColor(red: 95/255, green: 96/255, blue: 97/255, alpha: 1)
    }
    
    func primaryWhite() -> UIColor {
        return UIColor(red: 252/255, green: 238/255, blue: 224/255, alpha: 1)
    }
}

extension UIImage {
    
    var isPortrait : Bool { return size.height > size.width }
    var isLandscape : Bool { return size.width > size.height }
    var breadth : CGFloat { return min(size.width, size.height) }
    var breadthSize : CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect : CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    var circleMasked: UIImage? {
        
       UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer { UIGraphicsEndImageContext() }
        
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
