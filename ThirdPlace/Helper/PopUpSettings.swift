//
//  PopUpSettings.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/05/18.
//

import Foundation
import UIKit

class PopUpSettings {
    
    var popupView = UIView()
    var blurEffectView = UIView()
    var titleLabelText: String
    var contentLabelText: String
    
    var popupViewHeight: CGFloat
    
    //CardViewController用の変数
    var emptyDataView: UIView? = nil
    
    init(titleLabelText: String, contentLabelText: String, popupViewHeight: CGFloat) {
        self.titleLabelText = titleLabelText
        self.contentLabelText = contentLabelText
        self.popupViewHeight = popupViewHeight
    }
    
    func setupUI(view: UIView, addedView: UIView? = nil) {
        // ブラーの設定
        blurEffectView.frame = view.bounds
        blurEffectView.isHidden = true
        if let addedView = addedView {
            addedView.addSubview(blurEffectView)
        } else {
            view.addSubview(blurEffectView)
        }
        blurEffectView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.safeAreaLayoutGuide.leftAnchor,
                bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.safeAreaLayoutGuide.rightAnchor
//                paddingTop: 100,
//                paddingLeft: 30,
//                    paddingBottom: 200,
//                paddingRight: 30,
//                    width: 300,
//                height: popupViewHeight
        )
        
        
        // ポップアップの設定
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 10
        popupView.isHidden = true
        if let addedView = addedView {
            addedView.addSubview(popupView)
        } else {
            view.addSubview(popupView)
        }
        popupView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.safeAreaLayoutGuide.leftAnchor,
    //            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.safeAreaLayoutGuide.rightAnchor,
            paddingTop: 100,
            paddingLeft: 30,
    //            paddingBottom: 200,
            paddingRight: 30,
    //            width: 300,
            height: popupViewHeight
        )
        
        // ポップアップのコンテンツの設定
        addContentToDialog()
        blurEffectView.isUserInteractionEnabled = true
    }

    // ブラー効果ビューにタップジェスチャーを追加
    func addTapGestureToBlurEffectView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePopup))
        blurEffectView.addGestureRecognizer(tapGesture)
    }

    func addContentToDialog() {
        let titleLabel = UILabel()
        titleLabel.text = titleLabelText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        popupView.addSubview(titleLabel)
        titleLabel.anchor(
            top: popupView.topAnchor,
            left: popupView.leftAnchor,
    //            bottom: popupView.bottomAnchor,
            right: popupView.rightAnchor,
            paddingTop: 10,
            paddingLeft: 30,
    //            paddingBottom: 200,
            paddingRight: 30,
    //            width: 300,
            height: 30
            )
        
        let contentLabel = UILabel()
        contentLabel.text = contentLabelText
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.numberOfLines = 0
        popupView.addSubview(contentLabel)
        contentLabel.anchor(
            top: popupView.topAnchor,
            left: popupView.leftAnchor,
            bottom: popupView.bottomAnchor,
            right: popupView.rightAnchor,
            paddingTop: 50,
            paddingLeft: 30,
            paddingBottom: 30,
            paddingRight: 30
    //            width: 300,
    //            height: 400
            )
            
        let closeButton = UIButton() // ボタンの位置とサイズを調整
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20) // フォントサイズの調整
        closeButton.setTitleColor(.black, for: .normal) // ボタンのテキスト色を黒に設定
        closeButton.addTarget(self, action: #selector(togglePopup), for: .touchUpInside)
        popupView.addSubview(closeButton)
        closeButton.anchor(
            top: popupView.topAnchor,
    //            left: popupView.leftAnchor,
    //            bottom: popupView.bottomAnchor,
            right: popupView.rightAnchor,
            paddingTop: 10,
    //            paddingLeft: 30,
    //            paddingBottom: 200,
            paddingRight: 10,
            width: 20,
            height: 20
            )
    }

    @objc func togglePopup() {
        blurEffectView.isHidden = !blurEffectView.isHidden
        popupView.isHidden = !popupView.isHidden
    }



}
