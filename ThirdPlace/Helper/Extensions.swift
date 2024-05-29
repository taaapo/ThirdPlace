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

extension NSAttributedString.Key {
    
    static var overlayAttributes: [NSAttributedString.Key: Any] = [
//        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 42.0),
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0),
        NSAttributedString.Key.kern: 1.0
    ]
    
    static var shadowAttribute: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
        return shadow
    }()
    
    static var titleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25.0),
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
    
    static var subtitleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0),
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
}


extension UIView {
    
    func applyShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }

    
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, centerX: NSLayoutYAxisAnchor? = nil) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
        }
        if width > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if height > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    @discardableResult
    func anchorToSuperview() -> [NSLayoutConstraint] {
        
        return anchor(top: superview?.topAnchor,
                      left: superview?.leftAnchor,
                      bottom: superview?.bottomAnchor,
                      right: superview?.rightAnchor)
    }
}

//MARK: - Share App
extension UIViewController {
    
    func shareApp() {
        
        print("go to app store")
        let itemsToShare = [
            """
            こんにちは！
            「チャットするなら Third Place /匿名で簡単チャット」で新しい友達と匿名で楽しくお話しませんか？
            誰でもスグに使える簡単なチャットアプリです。今すぐダウンロードして、素敵な出会いを楽しんでください！
            """,
            URL(string: "https://apps.apple.com/us/app/チャットするならthird-place-匿名で簡単チャット/id6502250114")] as [Any]
        
        // UIActivityViewControllerを作成
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        // iPad用のポップオーバー設定（iPhoneでは不要）
//        if let popoverController = activityViewController.popoverPresentationController {
//            popoverController.sourceView = self.view
//            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//        }
        
        // UIActivityViewControllerを表示
        self.present(activityViewController, animated: true, completion: nil)
    }
}
