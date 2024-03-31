//
//  EditViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/29.
//

import UIKit
import ProgressHUD

class EditViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalityTextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: - Vars
    
    var personalities: [String] = []
    weak var personalitiesPickerView: UIPickerView?
    
    var worries: [String] = []
    weak var worriesPickerView: UIPickerView?
    
    //MARK: - View LyfeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundTouch()
        setupAboutMeTextView()
        setupPersonalitiesPickerView()
        setupWorriesPickerView()
        
        if FUser.currentUser() != nil {
            loadUserData()
        }
    }
    
    //ProfileTableIvewと同じように、userdefault？を使用して、各テキストに内容を表示させる
    
    //MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if isTextDataImputed() {
            
            saveUserData()
            self.dismiss(animated: true)
        } else {
            ProgressHUD.symbol("ユーザー名・性格・悩みを入力してください", name: "exclamationmark.circle")
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    
    @objc func editUserData() {
        
        let user = FUser.currentUser()!
        
        user.username = usernameTextField.text!
        user.personality = personalityTextField.text!
        user.worry = worryTextField.text!
        user.aboutMe = aboutMeTextView.text ?? ""
    }
    
    //MARK: - Save User Data
    private func saveUserData() {
        
        let user = FUser.currentUser()!
        
        user.username = usernameTextField.text!
        user.personality = personalityTextField.text!
        user.worry = worryTextField.text!
        user.aboutMe = aboutMeTextView.text!
        
        saveUserData(user: user)
    }
    
    private func saveUserData(user: FUser) {
        
        user.saveUserLocally()
        user.saveUserToFireStore()
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
    
    private func setupAboutMeTextView() {
        aboutMeTextView.layer.cornerRadius = 5
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
    
    //MARK: - LoadUserData
    private func loadUserData() {
        
        let currentUser = FUser.currentUser()!
        
        usernameTextField.text = currentUser.username
        personalityTextField.text = currentUser.personality
        worryTextField.text = currentUser.worry
        aboutMeTextView.text = currentUser.aboutMe
    }
    
    //MARK: - Helper
    @objc private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func isTextDataImputed() -> Bool {
        
        return usernameTextField.text != "" && personalityTextField.text != "" && worryTextField.text != ""
    }
    
}
