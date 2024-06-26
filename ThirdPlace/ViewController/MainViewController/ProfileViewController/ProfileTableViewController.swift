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
import AVFoundation
import Photos

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
    
    var alertTextFieldPassword: UITextField!
    
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
        
        ProgressHUD.dismiss()
        
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
    
    //MARK: - カメラアクセス許可
    func requestCameraAccess() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            // 初めてのリクエスト
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // アクセスが許可された
                    DispatchQueue.main.async {
                        self.startCamera()
                    }
                } else {
                    // アクセスが拒否された
                    DispatchQueue.main.async {
                        self.showSettingsAlert()
                    }
                }
            }
        case .authorized:
            // すでに許可されている
            startCamera()
        case .restricted, .denied:
            // アクセスが拒否または制限されている
            showSettingsAlert()
        @unknown default:
            // 他のケース（将来的に追加される可能性のあるケース）
            fatalError("Unhandled case")
        }
    }

    func startCamera() {
        // カメラの起動処理
        self.openCamera()
    }

    func showSettingsAlert() {
        let alert = UIAlertController(
            title: "カメラアクセスが必要です",
            message: "カメラへのアクセスが拒否されています。設定アプリでアクセスを許可してください。設定した画像は、他ユーザーがチャット相手を探す際に利用されます。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "設定を開く", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        
        // 現在表示しているViewControllerにアラートを表示
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - フォトライブラリアクセス許可
    func requestPhotoLibraryAccess() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .notDetermined:
            // 初めてのリクエスト
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    // アクセスが許可された
                    DispatchQueue.main.async {
                        self.accessPhotoLibrary()
                    }
                case .denied, .restricted:
                    // アクセスが拒否または制限された
                    DispatchQueue.main.async {
                        self.showPhotoLibrarySettingsAlert()
                    }
                case .limited:
                    // アクセスが限定的に許可された
                    DispatchQueue.main.async {
                        self.accessPhotoLibrary()
                    }
                case .notDetermined:
                    // 予期しないケース
                    fatalError("PHPhotoLibrary requestAuthorization completed with .notDetermined status")
                @unknown default:
                    // 他のケース（将来的に追加される可能性のあるケース）
                    fatalError("Unhandled case")
                }
            }
        case .authorized:
            // すでに許可されている
            accessPhotoLibrary()
        case .restricted, .denied:
            // アクセスが拒否または制限されている
            showPhotoLibrarySettingsAlert()
        case .limited:
            // アクセスが限定的に許可されている
            accessPhotoLibrary()
        @unknown default:
            // 他のケース（将来的に追加される可能性のあるケース）
            fatalError("Unhandled case")
        }
    }

    func accessPhotoLibrary() {
        // フォトライブラリへのアクセス処理
        self.openPhotoLibrary()
    }

    func showPhotoLibrarySettingsAlert() {
        let alert = UIAlertController(
            title: "写真ライブラリへのアクセスが必要です",
            message: "写真ライブラリへのアクセスが拒否されています。設定アプリでアクセスを許可してください。設定した画像は、他ユーザーがチャット相手を探す際に利用されます。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "設定を開く", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        
        // 現在表示しているViewControllerにアラートを表示
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
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
            self.requestCameraAccess()
//            self.openCamera()
        }))
        
        alertController.addAction(UIAlertAction(title: "ライブラリから選択する", style: .default, handler: { alert in
            self.requestPhotoLibraryAccess()
//            self.openPhotoLibrary()
        }))
        
        alertController.addAction(UIAlertAction(title: "おまかせ", style: .default, handler: { alert in
            
            self.selectImageRandomly()
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler:nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showEditOptions() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //メアドの変更で障害が出てしまうためコメントアウト。メアド変更したい場合はお問い合わせしてもらうフローにする。
//        alertController.addAction(UIAlertAction(title: "メールアドレスの変更", style: .default, handler: { (alert) in
//            
//            self.showChangeEmail()
//        }))
        
        alertController.addAction(UIAlertAction(title: "アカウント管理", style: .default, handler: { (alert) in
            self.showAccountManageOptions()
        }))
        
        alertController.addAction(UIAlertAction(title: "お問い合わせ", style: .default, handler: { (alert) in
            self.goToContactForm()
        }))
        
        alertController.addAction(UIAlertAction(title: "利用規約およびプライバシーポリシー", style: .default, handler: { (alert) in
            self.goToReadMe()
        }))
        
        alertController.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { (alert) in
            self.showLogOutUser()
        }))
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showAccountManageOptions() {
        
        let alertController = UIAlertController(title: "アカウント管理", message: nil, preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "パスワードの変更", style: .default, handler: { (alert) in
            self.showChangePassword()
        }))
        
        alertController.addAction(UIAlertAction(title: "アカウントの削除", style: .destructive, handler: { (alert) in
            self.showDeleteAccount()
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
    
    private func showLogOutUser() {
        
        let alertView = UIAlertController(title: "ログアウト", message: "ログアウトしてもよろしいですか？", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { action in
            self.logOutUser()
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func showChangePassword() {
        
        let alertView = UIAlertController(title: "パスワードの変更", message: "パスワードを変更してもよろしいですか？", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "変更", style: .destructive, handler: { action in
            
            self.changePassword()
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func showDeleteAccount() {
        
        let alertView = UIAlertController(title: "アカウントの削除", message: "アカウントを削除してもよろしいですか？", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { action in
            self.deleteUser()
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
    
    //MARK: - Delete
    private func deleteUser() {
        
//        let uid = FUser.currentId()
        
        let alertView = UIAlertController(title: "ユーザー認証", message: "パスワードを入力してください。", preferredStyle: .alert)
        
        alertView.addTextField { textField in
            self.alertTextFieldPassword = textField
            self.alertTextFieldPassword.isSecureTextEntry = true
            self.alertTextFieldPassword.placeholder = "パスワード"
        }
        
        alertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { action in
            
            FUser.deleteCurrentAccount(password: self.alertTextFieldPassword.text!) {error in
                
                if error == nil {
                    print("error is nil in alertView.addAction")
                    
//                    FirebaseReference(.User).document(uid).delete()
                    
                    //下記3つの関数の場所がわからない
//                    deleteAllLikeWith(userId: uid)
//                    deleteAllChatWith(userId: uid)
//                    deleteUserWith(userId: uid)
                    
                    ProgressHUD.symbol("アカウントの削除が完了しました。", name: "exclamationmark.circle")
                    
                    let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                    
                    DispatchQueue.main.async {
                        
                        loginView.modalPresentationStyle = .fullScreen
                        self.present(loginView, animated: true, completion: nil)
                        
                        print("アカウント削除完了 in alertView.addAction")
                    }
                    
                } else {
//                    ProgressHUD.symbol("エラーが発生しました。\nお問合せください", name: "exclamationmark.circle")
                    ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
                }
            }
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(alertView, animated: true, completion: nil)
        
    }
    
    //MARK: - Contact
    private func goToContactForm() {
        
        let url = NSURL(string: "https://forms.gle/P1yCcmNC1ksTX5sW7")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    private func goToReadMe() {
        
        let url = NSURL(string: "https://github.com/taaapo/ThirdPlace/blob/master/README.md")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}


