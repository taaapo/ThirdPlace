//
//  RegisterViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/12.
//

import UIKit
import ProgressHUD
import Firebase

class RegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalityTextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var comfirmPasswordTextField: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: - Vars
    var personalities: [String] = []
    weak var personalitiesPickerView: UIPickerView?
    
    var worries: [String] = []
    weak var worriesPickerView: UIPickerView?
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundTouch()
        setupProgressHUD()
        setupPersonalitiesPickerView()
        setupWorriesPickerView()
    }
    
    //MARK: - IBActions
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if isTextDataImputed() {
            
            if passwordTextField.text! == comfirmPasswordTextField.text! {
                registerUser()
            } else {
                ProgressHUD.symbol("パスワードが一致しません", name: "exclamationmark.circle")
            }
            
        } else {
            ProgressHUD.symbol("すべての項目を入力してください", name: "exclamationmark.circle")
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
        ProgressHUD.fontStatus = UIFont.boldSystemFont(ofSize: 19)
        ProgressHUD.colorStatus = UIColor(red:99/255, green:99/255, blue:100/255, alpha:1.0)
    }
    
    private func setupPersonalitiesPickerView() {
        
        appendPersonalitiesList()
        
        //Setup PickerView
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        personalityTextField.delegate = self
        personalityTextField.inputAssistantItem.leadingBarButtonGroups = []
        personalityTextField.inputView = pickerView
        self.personalitiesPickerView = pickerView
        
        //Setup tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    private func setupWorriesPickerView() {
        
        appendworriesList()
        
        //Setup PickerView
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        worryTextField.delegate = self
        worryTextField.inputAssistantItem.leadingBarButtonGroups = []
        worryTextField.inputView = pickerView
        self.worriesPickerView = pickerView
        
        //Setup tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    //MARK: - UIPickerViewDataSource Protocol
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == personalitiesPickerView {
            return personalities.count
        } else if pickerView == worriesPickerView {
            return worries.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == personalitiesPickerView {
            return personalities[row]
        } else if pickerView == worriesPickerView {
            return worries[row]
        } else {
            return "エラー"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == personalitiesPickerView {
            personalityTextField.text = personalities[row]
        } else if pickerView == worriesPickerView {
            worryTextField.text = worries[row]
        }
    }
    
    //MARK: - Helpers
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func isTextDataImputed() -> Bool {
        
        return usernameTextField.text != "" && personalityTextField.text != "" && worryTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && comfirmPasswordTextField.text != ""
    }
    
    //MARK: - Options of Personalities and Worries
    
    private func appendPersonalitiesList() {
        personalities.append("人懐っこい後輩タイプ")
        personalities.append("面倒見の良い先輩タイプ")
        personalities.append("誰とでもフラットな同期タイプ")
        personalities.append("みんなをまとめる部長タイプ")
        personalities.append("陰の立役者マネージャータイプ")
        //personalities.append("世話焼きな保護者タイプ")
        personalities.append("1人が好きなオオカミタイプ")
        personalities.append("みんなの癒しペットタイプ")
    }
    
    private func appendworriesList() {
        worries.append("健康、美容、容姿")
        worries.append("将来、夢、キャリア")
        worries.append("人間関係、恋愛、結婚")
        worries.append("お金")
        worries.append("その他")
        worries.append("悩みはない")
    }
    
    //MARK: - RegisterUser
    private func registerUser() {
        
        ProgressHUD.animate()
        
        FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, username: usernameTextField.text!, personality: personalityTextField.text!, worry: worryTextField.text!) { error in
            
            if error == nil {
                ProgressHUD.symbol("認証用メールを送信しました", name: "checkmark")
                self.dismiss(animated: true, completion: nil)
            } else {
                ProgressHUD.symbol(error!.localizedDescription, name: "exclamationmark.circle")
            }
        }
    }
}
