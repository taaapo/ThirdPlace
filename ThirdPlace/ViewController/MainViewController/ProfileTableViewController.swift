//
//  ProfileTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/02/18.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var editAndSaveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalitytextField: UITextField!
    @IBOutlet weak var worryTextField: UITextField!
    @IBOutlet weak var aboutMeTextField: UITextView!
    
    //MARK: - ViewLifrCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgrounds()
    }
    
    //MARK: - IBActions
    @IBAction func editAndSaveBarButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func settingsBarButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
    }
    
    //MARK: - Setup
    private func setupBackgrounds() {
        setupTableViewBackground()
        setupAboutMeTextField()
    }
    
    private func setupTableViewBackground() {
        let image = UIImage(named: "プロフィール画面背景")
        let imageView = UIImageView(frame: CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height))
        imageView.image = image
        self.tableView.backgroundView = imageView
    }
    
    private func setupAboutMeTextField() {
        aboutMeTextField.layer.cornerRadius = 5
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}
