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
    
    let refreshController = UIRefreshControl()
    
    let currentUser = MKSender(senderId: FUser.currentId(), displayName: FUser.currentUser()!.username)
    
    private var mkmessages: [MKMessage] = []
    var loadedMessageDictionry: [Dictionary<String, Any>] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationBarの左側のボタンのimageを変更したい場合、下記をコメントアウトして、configureLeftBatButtonにイメージを入れる
//        configureLeftBarButton()
        
        configureMesageCollectionView()
//        configureMessageInputBar()
    }
    
    //MARK: - Config
    private func configureLeftBarButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: ""), style: .plain, target: self, action: #selector(self.backButtonPressed))
    }
    
    private func configureMesageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        //下記をコメントアウトするとエラーになるが、なんでかわからない
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        //下記をコメントアウトするとエラーになるが、なんでかわからない
//        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }
    
//    private func configureMessageInputBar() {
//        
//        messageInputBar.delegate = self
//        
//        let button = InputBarButtonItem()
//        button.image = UIImage(named: "attach")
//        button.setSize(CGSize(width: 30, height: 30), animated: false)
//        
//        button.onTouchUpInside { (item) in
//            self.actionAttachMessage()
//        }
//        
//        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
//        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
//        
//        messageInputBar.inputTextView.isImagePasteEnabled = false
//        messageInputBar.backgroundView.backgroundColor = .systemBackground
//        messageInputBar.inputTextView.backgroundColor = .systemBackground
//    }
    
    //MARK: - Actions
    @objc func backButtonPressed() {
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChatViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        
        return mkmessages[indexPath.row]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        
        return mkmessages.count
    }
}

//画像を添付する機能を加えた場合、下記をコメントアウト
extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        print("tap on image message")
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    //ハッシュタグやメンションで色を変えたい場合は下記をコメントアウトする
//    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
//        
//        switch detector {
//        case .hashtag, .mention:
//            return [.foregroundColor: UIColor.blue]
//        default:
//            return MessageLabel.defaultAttributes
//        }
//    }
//    
//    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
//        
//        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
//    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? MessageDefaults.bubbleColorOutgoing : MessageDefaults.bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.count % 3 == 0 {
            
            return 18
        }
        
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //Avatarのimageにsenderのプロフィール画像を入れる
        avatarView.set(avatar: Avatar(image: UIImage(named: "プロフィール画像_ヒトの影_丸_v2")))
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
     
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("didPressSendButton")
        
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                //send message
                print("send message, ", text)
            }
        }
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

