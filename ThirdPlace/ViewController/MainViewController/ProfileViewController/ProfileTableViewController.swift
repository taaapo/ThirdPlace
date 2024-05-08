//
//  ProfileTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/18.
//

import UIKit
import Foundation
import ProgressHUD
import CropViewController

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
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
            
        }  else {
            
            print("current User is nil")
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
            
        }  else {
            
            print("current User is nil")
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
        aboutMeTextView.isEditable = false
        aboutMeTextView.isSelectable = false
        aboutMeTextView.isScrollEnabled = true
    }
    
    //MARK: - LoadUserData
    private func loadUserData() {
        
        let currentUser = FUser.currentUser()!
        
        usernameTextField.text = currentUser.username
        personalityTextField.text = currentUser.personality
        worryTextField.text = currentUser.worry
        aboutMeTextView.text = currentUser.aboutMe
        
//        avatarImageView.image = currentUser.avatar?.circleMasked
        
        FileStorage.downloadImage(imageUrl: currentUser.avatarLink) { image in
            self.avatarImageView.image = image?.circleMasked ?? UIImage(named: kPLACEHOLDERIMAGE)
        }
        
        print("loadUserData")
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
            self.imagePicker.allowsEditing = false
            self.imagePicker.delegate = self
//            imagePicker.cameraOverlayView = getOverlayViewOnCamera()
            imagePicker.navigationBar.topItem?.title = "写真"
            imagePicker.navigationBar.backItem?.title = "キャンセル"
            self.present(self.imagePicker, animated: true, completion: nil)
            
            } else {
                
                let alert  = UIAlertController(title: "警告", message: "このデバイスにはカメラがありません", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    private func openPhotoLibrary() {
        
        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.imagePicker.allowsEditing = false
        self.imagePicker.delegate = self
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    private func selectImageRandomly() {
        
        print("updating image view with image")
        
        let stringOfRandomInt = String(Int.random(in: 0..<27))
        let image = UIImage(named: "RandomImage_" + stringOfRandomInt)!
        
        self.avatarImageView.image = image.circleMasked
        self.avatarImage = image
        
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
    
    private func updateImageFlag() {
        
        let user = FUser.currentUser()!
        
        user.imageFlag = user.imageFlag + 1
        
        saveUserData(user: user)
    }
    
    //MARK: - FileStorae
    private func uploadAvatar(_ image: UIImage, completion: @escaping (_ avatarLink: String?) -> Void) {
        
        ProgressHUD.animate()
        
        updateImageFlag()
        
        let fileDirectory = "Avatars/_" + FUser.currentId() + "-" + String(FUser.currentUser()!.imageFlag) + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            
            ProgressHUD.dismiss()
            FileStorage.saveImageLocally(imageData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: FUser.currentId())
            completion(avatarLink)
        }
    }
    
    //MARK: - Save User Data
//    private func saveUserData() {
//        
//        let user = FUser.currentUser()!
//        
//        saveUserData(user: user)
//    }
    
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
        
        alertController.addAction(UIAlertAction(title: "おまかせ", style: .default, handler: { alert in
            
            self.selectImageRandomly()
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler:nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showEditOptions() {
        
        let alertController = UIAlertController(title: "アカウント情報の編集", message: nil, preferredStyle: .actionSheet)
        
        //メアドの変更で障害が出てしまうためコメントアウト。メアド変更したい場合はお問い合わせしてもらうフローにする。
//        alertController.addAction(UIAlertAction(title: "メールアドレスの変更", style: .default, handler: { (alert) in
//            
//            self.showChangeEmail()
//        }))
        
        alertController.addAction(UIAlertAction(title: "パスワードの変更", style: .default, handler: { (alert) in
            
            self.showChangePassword()
        }))
        
        alertController.addAction(UIAlertAction(title: "お問い合わせ", style: .default, handler: { (alert) in
            
            self.goToContactForm()
        }))
        
        alertController.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { (alert) in
            
            self.showLogOutUser()
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //画像の縦=横ではない場合にエラーメッセージを表示する実装だと、実機で試した際に何を選択してもエラーになってしまう。下記のURLを参考にしてみる
        //https://stackoverflow.com/questions/59930458/how-to-change-frame-size-of-uiimagepicker-when-i-get-photo-from-photolibrary-or
        //https://github.com/nkopilovskii/ImageCropper
        //https://qiita.com/tetsufe/items/9ff5fe190ee190afa1bb
        
        // Get the image from the info dictionary.
        if let originalImage = info[.originalImage] as? UIImage {
            
            let cropController = CropViewController(croppingStyle: .default, image: originalImage)
            cropController.doneButtonTitle = "完了"
            cropController.cancelButtonTitle = "キャンセル"
            cropController.delegate = self
            cropController.customAspectRatio = CGSize(width: 100, height: 100)
            
            //今回は使わないボタン等を非表示にする。
            cropController.aspectRatioPickerButtonHidden = true
            cropController.resetAspectRatioEnabled = false
            cropController.aspectRatioLockEnabled = true
            cropController.rotateButtonsHidden = true
            
            //cropBoxのサイズを固定する。
            cropController.cropView.cropBoxResizeEnabled = true
            //cropControllerを表示する。
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true, completion: nil)
            }
            
        }
        
        // Dismiss the UIImagePicker after selection
//        picker.dismiss(animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    //CropViewController
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
           updateImageViewWithImage(image, fromCropViewController: cropViewController)
       }
           
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        
        print("updating image view with image")
        
        self.avatarImageView.image = image.circleMasked
        self.avatarImage = image
        
        uploadAvatar(self.avatarImage!) { avatarLink in
            
            let user = FUser.currentUser()!
            
            user.avatarLink = avatarLink ?? ""
            user.avatar = self.avatarImage!
            
            FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                
                self.avatarImageView.image = image?.circleMasked
                
            }
            
            self.saveUserData(user: user)
            self.loadUserData()
            
            cropViewController.dismiss(animated: true, completion: nil)
        }
//        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helper for camera/phtolibrary functions
//    func isValidImage(_ image: UIImage) -> Bool {
//        
//        if image.cgImage?.width == image.cgImage?.height {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func displayErrorMessage() {
//        
//        ProgressHUD.symbol("枠が埋まるように写真のサイズを調整してください。", name: "exclamationmark.circle")
//    }
    
    //MARK: - Alert Actions
    private func showChangeEmail() {
        
        let alertView = UIAlertController(title: "メールアドレスの変更", message: nil, preferredStyle: .alert)
        
        alertView.addTextField { textField in
            self.alertTextFieldCurrentEmail = textField
            self.alertTextFieldCurrentEmail.placeholder = "現在のメールアドレス"
        }
        
        alertView.addTextField { textField in
            self.alertTextFieldCurrentPassword = textField
            self.alertTextFieldCurrentPassword.isSecureTextEntry = true
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
        
        if self.alertTextFieldCurrentPassword.text != "" 
            && self.alertTextFieldNewEmail.text != "" 
            && self.alertTextFieldCurrentPassword.text != "" {
            
            changeEmail()
            
        } else {
            ProgressHUD.symbol("すべての項目を入力してください。", name: "exclamationmark.circle")
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
            
            ProgressHUD.symbol("メールアドレスにパスワード変更用メールを送信しました", name: "checkmark")
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
    
    //MARK: - Contact
    private func goToContactForm() {
        
        let url = NSURL(string: "https://forms.gle/P1yCcmNC1ksTX5sW7")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}


