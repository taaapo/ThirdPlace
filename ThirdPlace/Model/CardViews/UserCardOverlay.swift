//
//  UserCardOverlay.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/11.
//

import Shuffle
import UIKit

class UserCardOverlay: UIView {
    
    init(direction: SwipeDirection) {
        super.init(frame: .zero)
        
        switch direction {
        case .left:
            createLeftOverlay()
        case .right:
            createRightOverlay()
        default:
            break
        }
        
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    
    private func createLeftOverlay() {
//        let leftTextView = SampleOverlayLabelView(withTitle: "◀︎次へ", color: UIColor().primaryGray(), rotation: CGFloat.pi/10)
        let leftTextView = SampleOverlayLabelView(withTitle: "◀︎次へ", color: UIColor().primaryGray(), rotation: 0)
        
        addSubview(leftTextView)
        leftTextView.anchor(top: topAnchor,
                            right: rightAnchor,
                            paddingTop: 26,
                            paddingRight: 30)
    }
    
    private func createRightOverlay() {
//        let rightTextView = SampleOverlayLabelView(withTitle: "いいね▶︎", color: UIColor().primaryRed(), rotation: -CGFloat.pi/10)
        let rightTextView = SampleOverlayLabelView(withTitle: "いいね▶︎", color: UIColor().primaryRed(), rotation: 0)
        
        addSubview(rightTextView)
        rightTextView.anchor(top: topAnchor,
                            left: leftAnchor,
                            paddingTop: 26,
                            paddingLeft: 26)

    }

    
}

private class SampleOverlayLabelView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    init(withTitle title: String, color: UIColor, rotation: CGFloat) {
        super.init(frame: CGRect.zero)
        layer.borderColor = color.cgColor
//        layer.borderWidth = 4
//        layer.cornerRadius = 1
        transform = CGAffineTransform(rotationAngle: rotation)
        
        addSubview(titleLabel)
        titleLabel.textColor = color
        titleLabel.attributedText = NSAttributedString(string: title,
                                                       attributes: NSAttributedString.Key.overlayAttributes)
        titleLabel.anchor(top: topAnchor,
                          left: leftAnchor,
                          bottom: bottomAnchor,
                          right: rightAnchor,
                          paddingLeft: 8,
                          paddingRight: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

