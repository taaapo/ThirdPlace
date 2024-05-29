//
//  LikesViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/31.
//

import UIKit
import ProgressHUD

class LikesViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    //MARK: - Vars
    var allLikes: [LikeObject] = []
    var allUsers: [FUser] = []
    
    //ExplanationMarkの挙動に必要
    let popupView = UIView()
    let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.8
        view.isHidden = true
        return view
    }()
    var popUpSettings = PopUpSettings(
        titleLabelText: "「いいね画面」の使い方",
        contentLabelText: """
                        ①「いいね」したユーザーの一覧が表示されます。各行をタップすると、ユーザーのプロフィール画面に遷移します。
                        
                        ②ユーザーのプロフィール画面の右上の編集ボタンをタップすると、チャット画面に遷移します。
                        """,
        popupViewHeight: 220
    )
    
    //MARK: - ViewLifecycle
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        downloadLikes()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ProgressHUD.dismiss()
        
        downloadLikes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        downloadLikes()
        
        //ExplanationMarkの挙動に必要
        popUpSettings.popupView = popupView
        popUpSettings.blurEffectView = blurEffectView
        popUpSettings.setupUI(view: self.view)
        popUpSettings.addTapGestureToBlurEffectView()
    }
    
    
    //MARK: - DownloadLikes
    
    private func downloadLikes() {
        
        ProgressHUD.animate()
        
        FirebaseListener.shared.downloadUserLikes { (allUserIds) in
            
            if allUserIds.count > 0 {
                
                FirebaseListener.shared.downloadUsersFromFirebase(withIds: allUserIds) { (allUsers) in
                    
                    ProgressHUD.dismiss()

                    self.allUsers = allUsers
                    self.allUsers.sort(by: { $0.username.compare($1.username) == ComparisonResult.orderedDescending })
                    //dump関数は与えられた値の出力を行う関数
                    dump(self.allUsers)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            } else {
                ProgressHUD.dismiss()
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func questionMarkPressed(_ sender: UIButton) {
        print("questionMarkPressed")
        popUpSettings.togglePopup()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        shareApp()
    }
    
    //MARK: - Navigation
    
    private func showUserProfileFor(user: FUser) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserProfileTableView") as! UserProfileTableViewController
        
        profileView.userObject = user
        profileView.isLikedUser = true
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}


extension LikesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LikeTableViewCell
        
        cell.setupCell(user: allUsers[indexPath.row])
        return cell
    }
}


extension LikesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        showUserProfileFor(user: allUsers[indexPath.row])
    }
}

