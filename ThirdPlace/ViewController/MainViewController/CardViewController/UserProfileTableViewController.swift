//
//  UserProfileTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/20.
//

import UIKit

protocol UserProfileTableViewControllerDelegate {
    func goToChat()
    func goToNext()
}

class UserProfileTableViewController: UITableViewController {

    //MARK: - IBOutelets
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalityTextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet var backgroundTableView: UITableView!
    
    //MARK: - Vars
    var userObject: FUser?
    var delegate: UserProfileTableViewControllerDelegate?
    
    //MARK: - View lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userObject != nil {
            showUserDetails()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupAboutMeTextField()
        notAllowedEditing()
    }
    
    //MARK: - IBActions
    @IBAction func goToChatButtonPressed(_ sender: UIButton) {
        self.delegate?.goToChat()
        dismissView()
    }
    
    @IBAction func goToNextButtonPressed(_ sender: UIButton) {
        self.delegate?.goToNext()
        dismissView()
    }
    
    //MARK: - TableViewDelegate
    //下記を加えることでheaderの高さが0になり、スクロール時に上部に白色のheaderが表示されなくなる
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - Setup
    private func setupTableView() {
        setupTableViewBackground()
        setupTableViewSectionFooter()
    }
    
    private func setupAboutMeTextField() {
        aboutMeTextView.layer.cornerRadius = 5
    }
    
    private func notAllowedEditing() {
        
        usernameTextField.isUserInteractionEnabled = false
        personalityTextField.isUserInteractionEnabled = false
        worryTextField.isUserInteractionEnabled = false
        aboutMeTextView.isUserInteractionEnabled = false
    }
    
    //MARK: - Show user profile
    private func showUserDetails() {
     
        usernameTextField.text = userObject!.username
        personalityTextField.text = userObject!.personality
        worryTextField.text = userObject!.worry
        aboutMeTextView.text = userObject!.aboutMe
        
        avatarImageView.image = userObject!.avatar?.circleMasked ?? UIImage(named: kPLACEHOLDERIMAGE)?.circleMasked
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
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

}
