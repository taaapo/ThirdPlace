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
            
            FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { error, isEmailVerified in
                
                if error != nil {
                    
                    print(error!.localizedDescription)
                    ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
                } else if isEmailVerified {
                    
                    //enter the application
                } else {
                    
                    ProgressHUD.symbol("メールを認証してください", name: "exclamationmark.circle")
                }
            }
        } else {
            ProgressHUD.symbol("すべての項目を入力してください", name: "exclamationmark.circle")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        
        if emailTextField.text != ""{
            //reset password
        } else {
            ProgressHUD.symbol("メールアドレスを入力してください", name: "exclamationmark.circle")
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
    }
    
    private func setupProgressHUD() {
        ProgressHUD.fontStatus = UIFont.boldSystemFont(ofSize: 20)
        ProgressHUD.colorStatus = UIColor(red:99/255, green:99/255, blue:100/255, alpha:1.0)
    }
    
    //MARK: - Gelpers
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
}
