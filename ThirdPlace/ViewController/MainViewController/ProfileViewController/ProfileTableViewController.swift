//
//  ProfileTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/18.
//

import UIKit
import Foundation
import ProgressHUD

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalityTextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var profileEditAndSaveImageView: UIImageView!
    @IBOutlet weak var profileEditAndSaveButton: UIButton!
    
    @IBOutlet var backgroundTableView: UITableView!
    
    //MARK: - Vars
    var avatarImage: UIImage?
    
    let imagePicker = UIImagePickerController()
    
    var alertTextFieldCurrentEmail: UITextField!
    var alertTextFieldCurrentPassword: UITextField!
    var alertTextFieldNewEmail: UITextField!
    
    //MARK: - ViewLifrCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FUser.currentUser() != nil {
            loadUserData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundTouch()
        setupTableView()
        setupAboutMeTextField()
        notAllowedEditing()
        
        if FUser.currentUser() != nil {
            loadUserData()
        } 
    }
    
    //MARK: - TableViewDelegate
    //下記を加えることでheaderの高さが0になり、スクロール時に上部に白色のheaderが表示されなくなる
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
    }
    
    private func isTextDataImputed() -> Bool {
        
        return usernameTextField.text != "" && personalityTextField.text != "" && worryTextField.text != ""
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        showEditOptions()
    }
    
    //MARK: - Setup
    private func setupTableView() {
        //背景画像を設定したい場合は下記をコメントアウト
//        setupTableViewBackground()
        setupTableViewSectionFooter()
    }
    
    private func setupAboutMeTextField() {
        aboutMeTextView.layer.cornerRadius = 5
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
    
    private func notAllowedEditing() {
        
        usernameTextField.isUserInteractionEnabled = false
        personalityTextField.isUserInteractionEnabled = false
        worryTextField.isUserInteractionEnabled = false
        aboutMeTextView.isUserInteractionEnabled = false
    }
    
    //MARK: - LoadUserData
    private func loadUserData() {
        
        let currentUser = FUser.currentUser()!
        
        usernameTextField.text = currentUser.username
        personalityTextField.text = currentUser.personality
        worryTextField.text = currentUser.worry
        aboutMeTextView.text = currentUser.aboutMe
        print(currentUser.aboutMe)
        
        print("loadUserData")
        
        avatarImageView.image = currentUser.avatar?.circleMasked
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
    
    private func openCamera() {
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                
                let alert  = UIAlertController(title: "警告", message: "このデバイスにはカメラがありません", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    private func openPhotoLibrary() {
        
        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - FileStorae
    private func uploadAvatar(_ image: UIImage, completion: @escaping (_ avatarLink: String?) -> Void) {
        
        ProgressHUD.animate()
        
        let fileDirectory = "Avatars/_" + FUser.currentId() + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            
            ProgressHUD.dismiss()
            FileStorage.saveImageLocally(imageData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: FUser.currentId())
            completion(avatarLink)
        }
    }
    
    //MARK: - Save User Data
    private func saveUserData() {
        
        let user = FUser.currentUser()!
        
        saveUserData(user: user)
    }
    
    private func saveUserData(user: FUser) {
        
        user.saveUserLocally()
        user.saveUserToFireStore()
    }
    
    //MARK: - AlertController
    private func showPictureOptions() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "写真を撮る", style: .default, handler: { alert in
            
            self.openCamera()
        }))
        
        alertController.addAction(UIAlertAction(title: "ライブラリから選択する", style: .default, handler: { alert in
            
            self.openPhotoLibrary()
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler:nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showEditOptions() {
        
        let alertController = UIAlertController(title: "アカウント情報の編集", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "メールアドレスの変更", style: .default, handler: { (alert) in
            
            self.showChangeEmail()
        }))
        
        alertController.addAction(UIAlertAction(title: "パスワードの変更", style: .default, handler: { (alert) in
            
            self.showChangePassword()
        }))
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (alert) in
            
            self.showLogOutUser()
        }))

        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Get the image from the info dictionary.
        if let editedImage = info[.editedImage] as? UIImage {
            
            self.avatarImageView.image = editedImage.circleMasked
            self.avatarImage = editedImage
            
            uploadAvatar(self.avatarImage!) { avatarLink in
                
                let user = FUser.currentUser()!
                
                user.avatarLink = avatarLink ?? ""
                user.avatar = self.avatarImage!
                
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    
                    self.avatarImageView.image = image?.circleMasked
                }
                
                self.saveUserData(user: user)
                self.loadUserData()
            }
        }
        
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Alert Actions
    private func showChangeEmail() {
        
        let alertView = UIAlertController(title: "メールアドレスの変更", message: nil, preferredStyle: .alert)
        
        alertView.addTextField { textField in
            self.alertTextFieldCurrentEmail = textField
            self.alertTextFieldCurrentEmail.placeholder = "現在のメールアドレス"
        }
        
        alertView.addTextField { textField in
            self.alertTextFieldCurrentPassword = textField
            self.alertTextFieldCurrentPassword.placeholder = "現在のパスワード"
        }
        
        alertView.addTextField { textField in
            self.alertTextFieldNewEmail = textField
            self.alertTextFieldNewEmail.placeholder = "新しいメールアドレス"
        }
        
        alertView.addAction(UIAlertAction(title: "変更", style: .destructive, handler: { action in
            
            self.updateEmail()
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func showChangePassword() {
        
        let alertView = UIAlertController(title: "パスワードの変更", message: "パスワードを変更してよろしいですか？", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "変更", style: .destructive, handler: { action in
            
            self.changePassword()
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    private func showLogOutUser() {
        
        let alertView = UIAlertController(title: "ログアウト", message: "ログアウトしてよろしいですか？", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { action in
            
            self.logOutUser()
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    //MARK: - Update Email/Password
    
    private func updateEmail() {
        
        if self.alertTextFieldCurrentPassword.text != "" && self.alertTextFieldNewEmail.text != "" {
            changeEmail()
        } else {
            ProgressHUD.symbol("現在のパスワードと新しいメールアドレスを入力してください。", name: "checkmark")
        }
    }
    
    private func changeEmail() {
        
        let user = FUser.currentUser()!
        
        user.updateUserEmail(beforeEmail: alertTextFieldCurrentEmail.text!, password: alertTextFieldCurrentPassword.text!, newEmail: alertTextFieldNewEmail.text!) { error in
            
            if error == nil {
                
                if let currentUser = FUser.currentUser() {
                    currentUser.email = self.alertTextFieldNewEmail.text!
                    self.saveUserData(user: currentUser)
                }
                ProgressHUD.symbol("メールアドレスに認証用メールを送信しました", name: "checkmark")
            } else {
                ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
                print(error!)
            }
        }
    }
    
    private func changePassword() {
        
        FUser.resetPasswordFor(email: FUser.currentUser()!.email) { error in
            
            if error == nil {
            
            ProgressHUD.symbol("メールアドレスに認証用メールを送信しました", name: "checkmark")
            } else {
                
                ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
                print(error!)
            }
        }
    }
    
    //MARK: - LogOut
    private func logOutUser() {
        
        FUser.logOutCurrentUser { error in
            
            if error == nil {
                
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
                
            } else {
                
                ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
            }
        }
    }
}


