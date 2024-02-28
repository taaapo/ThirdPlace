//
//  ProfileTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/18.
//

import UIKit
import Foundation
import ProgressHUD

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalityTextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var aboutMeTextField: UITextView!
    
    @IBOutlet weak var profileEditAndSaveImageView: UIImageView!
    @IBOutlet weak var profileEditAndSaveButton: UIButton!
    
    @IBOutlet var backgroundTableView: UITableView!
    
    //MARK: - Vars
    var editingMode = false
    
    //MARK: - ViewLifrCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundTouch()
        setupTableView()
        setupAboutMeTextField()
        
        if FUser.currentUser() != nil {
            loadUserData()
            updateEditingMode()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - IBActions

    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        showPictureOptions()
    }
    
    @IBAction func profileEditAndSaveButtonPressed(_ sender: UIButton) {
        
//        下から全画面で出てくるタイプ
        let editView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "EditView")

        editView.modalPresentationStyle = .fullScreen
        self.present(editView, animated: true, completion: nil)
        
//        if !editingMode {
//            
//            editingMode = true
//            updateEditingMode()
//            setupButton(title: "保存", titleColor: .white, buttonImage: "保存ボタン_v8")
//        } else {
//            
//            if isTextDataImputed() {
//                
//                saveUserData()
//                editingMode = false
//                updateEditingMode()
//                setupButton(title: "プロフィール編集", titleColor: UIColor().primaryGray(), buttonImage: "ボタン")
//            } else {
//                
//                ProgressHUD.symbol("ユーザー名・性格・悩みを入力してください", name: "exclamationmark.circle")
//            }
//        }
    }
    
    private func isTextDataImputed() -> Bool {
        
        return usernameTextField.text != "" && personalityTextField.text != "" && worryTextField.text != ""
    }
    
    private func saveUserData() {
        
        let user = FUser.currentUser()!
        
        user.username = usernameTextField.text!
        user.personality = personalityTextField.text!
        user.worry = worryTextField.text!
        user.aboutMe = aboutMeTextField.text!
    }
    
    //MARK: - Setup
    private func setupTableView() {
        setupTableViewBackground()
        setupTableViewSectionFooter()
    }
    
    private func setupAboutMeTextField() {
        aboutMeTextField.layer.cornerRadius = 5
    }
    
    private func setupButton(title: String, titleColor: UIColor, buttonImage: String) {
        
        profileEditAndSaveButton.setTitle(title, for: .normal)
        profileEditAndSaveButton.setTitleColor(titleColor, for: .normal)
        
        let imageSize = profileEditAndSaveImageView.image!.size
        let image = UIImage(named: buttonImage)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let scaleImage = renderer.image { _ in
            image!.draw(in: CGRect(origin: .zero, size: imageSize))
        }
        
        profileEditAndSaveImageView.image = scaleImage
    }
    
    private func setupBackgroundTouch() {
        backgroundTableView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundTableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        dismissKeyboard()
    }
    
    //MARK: - LoadUserData
    private func loadUserData() {
        
        let currentUser = FUser.currentUser()!
        
        avatarImageView.image = nil
        //TODO: set avatar picture.
        
        usernameTextField.text = currentUser.username
        personalityTextField.text = currentUser.personality
        worryTextField.text = currentUser.worry
        aboutMeTextField.text = currentUser.aboutMe
    }
    
    //MARK: - Editing Mode
    private func updateEditingMode() {
        
        usernameTextField.isUserInteractionEnabled = editingMode
        personalityTextField.isUserInteractionEnabled = editingMode
        worryTextField.isUserInteractionEnabled = editingMode
        aboutMeTextField.isUserInteractionEnabled = editingMode
    }
    
    //MARK: - Helper
    private func setupTableViewBackground() {
        let image = UIImage(named: "登録画面背景_v2")
        let imageView = UIImageView(frame: CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height))
        imageView.image = image
        self.tableView.backgroundView = imageView
    }
    
    private func setupTableViewSectionFooter() {
        tableView.estimatedSectionFooterHeight = 0.0
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    //MARK: - AlertController
    private func showPictureOptions() {
        
        let alertController = UIAlertController(title: "アップロード", message: "プロフィール画像を変更", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "プロフィール画像を変更", style: .default, handler: { alert in
            
            print("change Avatar")
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler:nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
