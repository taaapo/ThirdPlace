//
//  ChatListTableViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/22.
//

import UIKit

class ChatListTableViewController: UITableViewController {
    
    //MARK: - Vars
    var chatList: [Chat] = []
    
    //MARK: - ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        downloadChats()
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
        
        // 非表示処理
        let deleteAction = UIContextualAction(style: .normal, title: "非表示") { (action, view, completionHandler) in
            
            //非表示処理を記述
            self.showAction(title: "非表示", message: "メッセージを非表示にしてもよろしいですか？", completion: { result in
                
                if result {
                    //Chatsの削除
                    //「メッセージが非表示になります。「いいね」欄にユーザーが表示されている場合は、ユーザーをタップし、右上の編集ボタンからメッセージ画面に遷移できます。新しいメッセージを送信すると、チャット画面にメッセージが再表示されます。」
                    FirebaseListener.shared.deleteChatsFromFireStore(chat: self.chatList[indexPath.row])
                    self.chatList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // ブロック処理
        let blockAction = UIContextualAction(style: .destructive, title: "ブロック") { (action, view, completionHandler) in
            print("get action, view, completionHandler")
            // 編集処理を記述
            self.showAction(title: "ブロック", message: "ユーザーをブロックしてもよろしいですか？", completion: { result in
                
                print("get result")
                if result {
                    print("result is true")
                    
                    //Like削除
                    //TODO: ブロックした相手がUserProfileからチャットした場合、チャット画面に出てきてしまうため、修正が必要
                    //TODO: いいね画面でユーザーを表示したまま、そのユーザーをブロックした場合、いいね画面に戻ってきて操作をするとエラーにならないかテスト必要
                    deleteLikeToUser(userId: self.chatList[indexPath.row].receiverId)
                    print("after deleteLikeToUser")
                    
                    //blickedIdArray追加
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
        
        // 報告処理
        let reportAction = UIContextualAction(style: .destructive, title: "報告") { (action, view, completionHandler) in
            // 編集処理を記述
            self.showAction(title: "報告", message: "ユーザーを報告してもよろしいですか？", completion: { result in
                
                if result {
                    print("報告")
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
}

