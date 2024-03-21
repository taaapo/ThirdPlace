//
//  ChatViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/20.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import Firebase

class ChatViewController: MessagesViewController {
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    //MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
