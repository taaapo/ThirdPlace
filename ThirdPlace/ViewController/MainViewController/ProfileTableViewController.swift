//
//  ProfileTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/18.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalitytextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var aboutMeTextField: UITextView!
    
    //MARK: - Vars
    var editingMode = false
    
    //MARK: - ViewLifrCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableViewBackground()
        setupAboutMeTextField()
//        setupNavigationBar()
//        setupEditAndSaveBarButton()
        updateEditingMode()
        //self.navigationController?.navigationBar.barTintColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - IBActions

    @IBAction func cameraButtonPressed(_ sender: UIButton) {
    }
    
    //MARK: - Setup
    private func setupTableViewBackground() {
        let image = UIImage(named: "プロフィール画面背景")
        let imageView = UIImageView(frame: CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height))
        imageView.image = image
        self.tableView.backgroundView = imageView
    }
    
    private func setupAboutMeTextField() {
        aboutMeTextField.layer.cornerRadius = 5
    }
    
//    private func setupEditAndSaveBarButton() {
//        editAndSaveBarButton.title
//    }
    
    private func setupNavigationBar() {
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = .default
        navigationBar.isTranslucent = true
        navigationBar.tintColor = UIColor(red: 253/255, green: 87/255, blue: 86/255, alpha: 1)
    }
    
    //MARK: - Editing Mode
    private func updateEditingMode() {
        
        usernameTextField.isUserInteractionEnabled = editingMode
        personalitytextField.isUserInteractionEnabled = editingMode
        worryTextField.isUserInteractionEnabled = editingMode
        aboutMeTextField.isUserInteractionEnabled = editingMode
    }
    
}
