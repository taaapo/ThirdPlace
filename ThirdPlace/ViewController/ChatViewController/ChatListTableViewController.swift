//
//  ChatListTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/22.
//

import UIKit
import ProgressHUD

class ChatListTableViewController: UITableViewController {
    
    //MARK: - Vars
    var chatList: [Chat] = []
    
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
        titleLabelText: "「メッセージ画面」の使い方",
        contentLabelText: """
                        ①チャットしているユーザーの一覧が表示されます。各行をタップすると、チャット画面に遷移します。
                        
                        ②各行を左にスワイプすると、非表示ボタンが表示されます。メッセージを再表示する場合は、「いいね」画面から該当ユーザーのチャット画面に遷移し、新しいメッセージを送信するとメッセージが再表示されます。「いいね」画面にユーザーがいない場合、相手からチャットが来ない限りメッセージは再表示されません。
                        
                        ③各行を左にスワイプすると、ブロックボタンが表示されます。ユーザーをブロックすると、メッセージ画面といいね画面からユーザーが表示されなくなります。ブロックしたユーザーがメッセージを送信しても表示されません。
                        """,
        popupViewHeight: 450
    )
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProgressHUD.dismiss()
        
        setupTableView()
        downloadChats()
        
        //ExplanationMarkの挙動に必要
        popUpSettings.popupView = popupView
        popUpSettings.blurEffectView = blurEffectView
        popUpSettings.setupUI(view: self.view)
        popUpSettings.addTapGestureToBlurEffectView()
    }
    
    
    //MARK: - Download
    private func downloadChats() {
        
        FirebaseListener.shared.downloadChatsFromFireStore { allChats in
            
            self.chatList = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func questionMarkPressed(_ sender: UIButton) {
        popUpSettings.togglePopup()
    }
    
    //MARK: - Navigation
    private func goToChat(chat: Chat) {
        
        restartChat(chatRoomId: chat.chatRoomId, memberIds: chat.memberIds)
        
        FirebaseListener.shared.downloadUsersFromFirebase(withIds: [chat.receiverId]) { users in
            
            for user in users {
                
                let chatView = ChatViewController(chatId: chat.chatRoomId, recipientId: chat.receiverId, recipientName: chat.receiverName, senderImageLink: (FUser.currentUser()?.avatarLink)!, recipientImageLink: user.avatarLink)
                
                chatView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatView, animated: true)
            }
        }
        
        
    }
    
    //MARK: - TableView DataSorce & Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatListTableViewCell
        
        cell.generateCell(chat: chatList[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        goToChat(chat: chatList[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let chat = self.chatList[indexPath.row]
            chat.deleteChat()
            
            self.chatList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
//    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "削除"
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //MARK: - 非表示処理
        //「メッセージが非表示になります。「いいね」欄にユーザーが表示されている場合は、ユーザーをタップし、右上の編集ボタンからメッセージ画面に遷移できます。新しいメッセージを送信すると、チャット画面にメッセージが再表示されます。」
        let deleteAction = UIContextualAction(style: .normal, title: "非表示") { (action, view, completionHandler) in
            
            //非表示処理を記述
            self.showAction(title: "非表示", message: "メッセージを非表示にしてもよろしいですか？", completion: { result in
                
                if result {
                    //Chatsの削除
                    FirebaseListener.shared.deleteChatsFromFireStore(chat: self.chatList[indexPath.row])
                    self.chatList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        //MARK: - ブロック処理
        //「メッセージ画面といいね画面からブロックしたユーザーが表示されなくなります。ブロックしたユーザーがメッセージを送信しても表示されません。」※ブロック中にいいね画面で該当ユーザーのプロフィールを見ていた場合、メッセージが送信できてしまう。ただ、いいね画面に戻ると、該当ユーザーがいいね画面から消える。
        let blockAction = UIContextualAction(style: .destructive, title: "ブロック") { (action, view, completionHandler) in
            print("get action, view, completionHandler")
            // 編集処理を記述
            self.showAction(title: "ブロック", message: "ユーザーをブロックしてもよろしいですか？", completion: { result in
                
                print("get result")
                if result {
                    print("result is true")
                    
                    //Like削除 & UserのlikedIdArrayから削除
                    deleteLikeToUser(userId: self.chatList[indexPath.row].receiverId)
                    print("after deleteLikeToUser")
                    
                    
                    //UserのblickedIdArrayに追加
                    saveblockToUser(userId: self.chatList[indexPath.row].receiverId)
                    print("after saveblockToUser")
                    
                    //チャット削除
                    FirebaseListener.shared.deleteChatsFromFireStore(chat: self.chatList[indexPath.row])
                    self.chatList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("after chatList.remove")
                    
//                    tableView.reloadData()
                    
                    print("ブロック完了")
                }
            })
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [deleteAction, blockAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //MARK: - 報告処理
        let reportAction = UIContextualAction(style: .destructive, title: "報告") { (action, view, completionHandler) in
            // 編集処理を記述
            self.showAction(title: "報告", message: "ユーザーを報告してもよろしいですか？", completion: { result in
                
                if result {
                    self.goToReportForm()
                }
            })
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [reportAction])
    }
    
    //下記を加えることでheaderの高さが0になり、スクロール時に上部に白色のheaderが表示されなくなるけど、このViewではNavigation Varがあるため、変わらない
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    //MARK: - Alert Actions
    private func showAction(title: String, message: String, completion: @escaping (Bool) -> Void) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: title, style: .destructive, handler: { action in
            
            if title == "非表示" {
                completion(true)
            } else if title == "報告" {
                completion(true)
            } else if title == "ブロック" {
                completion(true)
            }
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    //MARK: - Setup
    private func setupTableView() {
        //背景画像を設定したい場合は下記をコメントアウトする
//        setupTableViewBackground()
        setupTableViewSectionFooter()
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
    
//    private func setAvatar(avatarLink: String) -> UIImage?{
//        
//        var setAvatarImage = UIImage(named: kPLACEHOLDERIMAGE)
//        
//        FileStorage.downloadImage(imageUrl: avatarLink) { avatarImage in
//            if avatarImage != nil {
//                setAvatarImage =  avatarImage?.circleMasked
//            }
//        }
//        return setAvatarImage
//    }
    
    //MARK: - Contact
    private func goToReportForm() {
        
        let url = NSURL(string: "https://forms.gle/2Cph8xYLZB8TMTWR8")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}

