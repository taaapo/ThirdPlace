//
//  LoginViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/12.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    

    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        setupBackgroundTouch()
        setupProgressHUD()
    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            ProgressHUD.animate()
            
            FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { error, isEmailVerified in
                
                if error != nil {
                    
                    print(error!.localizedDescription)
                    ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
                } else if isEmailVerified {
                    
                    ProgressHUD.dismiss()
                    self.goToApp()
                } else {
                    
                    ProgressHUD.symbol("メールを認証してください。", name: "exclamationmark.circle")
                }
            }
        } else {
            ProgressHUD.symbol("すべての項目を入力してください。", name: "exclamationmark.circle")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        
        if emailTextField.text != ""{
            
            FUser.resetPasswordFor(email: emailTextField.text!) { error in
                
                if error != nil {
                    print(error!)
                    ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle", delay: 5)
                } else {
                    
                    ProgressHUD.symbol("パスワード再設定用メールを送信しました。メールが来ない場合はメールアドレスが登録されていません。", name: "exclamationmark.circle", delay: 6)
                }
            }
            
        } else {
            ProgressHUD.symbol("メールアドレスを入力してください。", name: "exclamationmark.circle")
        }
    }
    
    //MARK: - Setup
    
    private func setupBackgroundTouch() {
        backgroundImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        dismissKeyboard()
        ProgressHUD.dismiss()
    }
    
    private func setupProgressHUD() {
        ProgressHUD.fontStatus = UIFont.boldSystemFont(ofSize: 19)
        ProgressHUD.colorStatus = UIColor(red:99/255, green:99/255, blue:100/255, alpha:1.0)
        //ProgressHUD.mediaSize = 100
        //ProgressHUD.marginSize = 50
    }
    
    //MARK: - Helpers
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    //MARK: - Navigation
    private func goToApp() {
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
}
