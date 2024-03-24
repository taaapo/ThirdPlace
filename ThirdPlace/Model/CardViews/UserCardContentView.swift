//
//  UserCardContentView.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/11.
//

import UIKit

class UserCardContentView: UIView {
    
    private let backgroundView: UIView = {
        let background = UIView()
        background.clipsToBounds = true
        background.layer.cornerRadius = 10
        background.backgroundColor = UIColor().primaryWhite()
        return background
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    init(withImage image: UIImage?) {
        super.init(frame: .zero)
        
        imageView.image = image
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 10
        initializer()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func initializer() {
        
        addSubview(backgroundView)
        //下記でCardStackに対するbackgroundViewの位置を設定
        backgroundView.anchorToSuperview()
        backgroundView.addSubview(imageView)
        //下記でbackgroundViewに対するimageViewの位置を設定
        imageView.anchor(left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor, paddingLeft: 30, paddingBottom: 145, paddingRight: 30, height: 270)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        
    }
}

