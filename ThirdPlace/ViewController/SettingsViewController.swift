//
//  SettingsViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/09.
//

import UIKit
import ProgressHUD

class SettingsViewController: UIViewController {
    
    //MARK: - Vars
    var alertTextFieldCurrentEmail: UITextField!
    var alertTextFieldCurrentPassword: UITextField!
    var alertTextFieldNewEmail: UITextField!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: - IBActions
    @IBAction func changeEmailButtonPressed(_ sender: UIButton) {
        self.showChangeEmail()
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        self.showChangePassword()
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        self.showLogOutUser()
    }
    
    //MARK: - Alert Actions
    private func showChangeEmail() {
        
        let alertView = UIAlertController(title: "メールアドレスの変更", message: "下記を入力してください。", preferredStyle: .alert)
        
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
    
    //MARK: - Save User Data
    private func saveUserData() {
        
        let user = FUser.currentUser()!
        
        saveUserData(user: user)
    }
    
    private func saveUserData(user: FUser) {
        
        user.saveUserLocally()
        user.saveUserToFireStore()
    }
}

