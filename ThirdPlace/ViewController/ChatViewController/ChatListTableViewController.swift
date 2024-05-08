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
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    //下記を加えることでheaderの高さが0になり、スクロール時に上部に白色のheaderが表示されなくなるけど、このViewではNavigation Varがあるため、変わらない
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    
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

