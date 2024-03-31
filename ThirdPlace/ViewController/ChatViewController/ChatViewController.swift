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
    
    var senderImage = UIImage(named: "プロフィール画像_ライオン")
    var recipientImage = UIImage(named: "プロフィール画像_ライオン")
    
    let refreshController = UIRefreshControl()
    
    let currentUser = MKSender(senderId: FUser.currentId(), displayName: FUser.currentUser()!.username)
    
    private var mkmessages: [MKMessage] = []
    var loadedMessageDictionaries: [Dictionary<String, Any>] = []
    
    var initialLoadCompleted = false
    var displayingMessagesCount = 0
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    
    var typingCounter = 0
    
    //Listeners
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updateChatListener: ListenerRegistration?

    //MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String, senderImage: UIImage, recipientImage: UIImage) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
        self.senderImage = senderImage
        self.recipientImage = recipientImage
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        setChatTitle()
//        createTypingObserver()
        
        configureLeftBarButton()
        configureMessageCollectionView()
        configureMessageInputBar()
        
        listenForReadStatusChange()
        downloadChats()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirebaseListener.shared.resetUnreadCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("will disappear")
        removeListeners()
        FirebaseListener.shared.resetUnreadCounter(chatRoomId: chatId)
    }
    
    //MARK: - Config
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        
        
    }
    
    private func configureMessageCollectionView() {

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
//        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
        
    }
    
    
    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        
//        inputBarの左側にItemを追加したい場合は下記をコメントアウト
//        let button = InputBarButtonItem()
//        //UIImageを挿入する
//        button.image = UIImage(named: "")
//        button.setSize(CGSize(width: 30, height: 30), animated: false)
//        
//        button.onTouchUpInside { (item) in
//            self.actionAttachMessage()
//        }
//        
//        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
//        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        //下記リンクを参考にした
        //https://note.com/npaka/n/n1dc30f6b371d
        messageInputBar.sendButton.title = "送信"
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    private func setChatTitle() {
        self.title = recipientName
    }

    //MARK: - Actions
    @objc func backButtonPressed() {
        
        FirebaseListener.shared.resetUnreadCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }

    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()

        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)

    }
    
    private func messageSend(text: String) {
        
        OutgoingMessage.send(chatId: chatId, text: text, memberIds: [FUser.currentId(), recipientId])
    }
    
    
    //MARK: - Download chats
    
    private func downloadChats() {
        
        FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).limit(to: 15).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                
                self.initialLoadCompleted = true
                //listen for new chats
                return
            }

            
            self.loadedMessageDictionaries = ((self.dictionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [Dictionary<String, Any>]
            

            self.insertMessages()
            self.messagesCollectionView.reloadData()
            //self.messagesCollectionView.scrollToBottom()
            self.messagesCollectionView.scrollToLastItem()
            
            
            self.initialLoadCompleted = true
            
            
            self.getOldMessagesInBackground()
            self.listenForNewChats()
        }
    }
    
    
    private func listenForNewChats() {
        
        newChatListener = FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).whereField(kDATE, isGreaterThan: lastMessageDate()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for change in snapshot.documentChanges {
                    
                    if change.type == .added {
                        
                        self.insertMessage(change.document.data())
                        self.messagesCollectionView.reloadData()
                        //self.messagesCollectionView.scrollToBottom(animated: true)
                        self.messagesCollectionView.scrollToLastItem()
                    }
                }
            }
        })
    }
    
    
    private func getOldMessagesInBackground() {

        if loadedMessageDictionaries.count > kNUMBEROFMESSAGES {

            FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).whereField(kDATE, isLessThan: firstMessageDate()).getDocuments { (snapshot, error) in
                
                
                guard let snapshot = snapshot else { return }
                
                self.loadedMessageDictionaries = ((self.dictionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [Dictionary<String, Any>] + self.loadedMessageDictionaries
                
                
                self.messagesCollectionView.reloadData()

                self.maxMessageNumber = self.loadedMessageDictionaries.count - self.displayingMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
            }
        }
        
    }
    
    
    private func listenForReadStatusChange() {
        
        updateChatListener = FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).addSnapshotListener({ (snapshot, error) in
            
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                snapshot.documentChanges.forEach { (change) in
                    
                    if change.type == .modified {
                        
                        self.updateMessage(change.document.data())
                    }
                }
            }
        })
    }
    
    private func updateMessage(_ messageDictionary: Dictionary<String, Any>) {
        
        for index in 0 ..< mkmessages.count {
            
            let tempMessage = mkmessages[index]
            
            if messageDictionary[kOBJECTID] as! String == tempMessage.messageId {
                
                mkmessages[index].status = messageDictionary[kSTATUS] as? String ?? kSENT

                if mkmessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
            
        }
        
    }
    
    //MARK: - InsertMessages
    private func insertMessages() {
        
        maxMessageNumber = loadedMessageDictionaries.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            
            let messageDictionary = loadedMessageDictionaries[i]
            insertMessage(messageDictionary)
            displayingMessagesCount += 1
        }
    }
    
    private func insertMessage(_ messageDictionary: Dictionary<String, Any>) {
        
        markMessageAsRead(messageDictionary)
        
        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.append(incoming.createMessage(messageDictionary: messageDictionary)!)
    }
    
    private func insertOldMessage(_ messageDictionary: Dictionary<String, Any>) {

        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.insert(incoming.createMessage(messageDictionary: messageDictionary)!, at: 0)
    }

    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        if loadOld {
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            print("i is, ", i)
            let messageDictionary = loadedMessageDictionaries[i]
            insertOldMessage(messageDictionary)
            displayingMessagesCount += 1
        }
        
        loadOld = true
    }
    
    
    private func markMessageAsRead(_ messageDictionary: Dictionary<String, Any>) {
        
        if messageDictionary[kSENDERID] as! String != FUser.currentId() {
            OutgoingMessage.updateMessage(withId: messageDictionary[kOBJECTID] as! String, chatRoomId: chatId, memberIds: [FUser.currentId(), recipientId])
        }
    }
    
    private func removeListeners() {
        
        if newChatListener != nil {
            newChatListener!.remove()
        }
        
        if typingListener != nil {
            typingListener!.remove()
        }
        
        if updateChatListener != nil {
            updateChatListener!.remove()
        }
    }

    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            
            if displayingMessagesCount <  loadedMessageDictionaries.count {
                
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
        }
        refreshController.endRefreshing()
    }


    
    //MARK: - Helpers
    
    private func dictionaryArrayFromSnapshot(_ snapshots: [DocumentSnapshot]) -> [Dictionary<String, Any>] {
        
        var allMessages: [Dictionary<String, Any>] = []
        
        for snapshot in snapshots {
            allMessages.append(snapshot.data()!)
        }
        
        return allMessages
    }

    private func lastMessageDate() -> Date {
        
        let lastMessageDate = (loadedMessageDictionaries.last?[kDATE] as? Timestamp)?.dateValue() ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    
    private func firstMessageDate() -> Date {
        
        let firstMessageDate = (loadedMessageDictionaries.first?[kDATE] as? Timestamp)?.dateValue() ?? Date()
        return Calendar.current.date(byAdding: .second, value: -1, to: firstMessageDate) ?? firstMessageDate
    }
    
    //MARK: - Typing indicator
    
//    private func createTypingObserver() {
//        
//        TypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
//            
//            self.setTypingIndicatorViewHidden(!isTyping, animated: false, whilePerforming: nil) { [weak self] success in
//                
//                if success, self?.isLastSectionVisible() == true {
//                    self?.messagesCollectionView.scrollToBottom(animated: true)
//                }
//            }
//        }
//    }

    private func typingIndicatorUpdate() {
        
        typingCounter += 1
        
        TypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingCounterStop()
        }
    }
    
    
    private func typingCounterStop() {
        
        typingCounter -= 1
        if typingCounter == 0 {
            TypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !mkmessages.isEmpty else {
            return false
        }
        
        let lastIndexPath = IndexPath(item: 0, section: mkmessages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
      
}


extension ChatViewController : MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        currentUser
    }
    
//    func currentSender() -> SenderType {
//        return currentUser
//    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return mkmessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return mkmessages.count
    }
    
    
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        
//        if indexPath.section % 3 == 0 {
//
//            let showLoadMore = (indexPath.section == 0) && loadedMessageDictionaries.count > displayingMessagesCount
//            
//            let text = showLoadMore ? "" : MessageKitDateFormatter.shared.string(from: message.sentDate)
//            let font = showLoadMore ? UIFont.boldSystemFont(ofSize: 15) : UIFont.boldSystemFont(ofSize: 10)
//            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
//            
//            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
//        }
//        return nil
//    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isFromCurrentSender(message: message) {
            let message = mkmessages[indexPath.section]
            let status = indexPath.section == mkmessages.count - 1 ? message.status : ""
            
            return NSAttributedString(string: status, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
            
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
          
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let yearFormatter = DateFormatter()
        yearFormatter.locale = Locale(identifier: "ja_JP")
        yearFormatter.dateFormat = "yyyy"
        yearFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let formatter = DateFormatter()
        yearFormatter.locale = Locale(identifier: "ja_JP")
        yearFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        if dateFormatter.string(from: mkmessages[indexPath.section].sentDate) == dateFormatter.string(from: Date()) {
            
            formatter.dateFormat = "H:mm"
            
        } else if yearFormatter.string(from: mkmessages[indexPath.section].sentDate) == yearFormatter.string(from: Date()) {
            
            formatter.dateFormat = "M/d H:mm"
            
        } else {
            
            formatter.dateFormat = "yyyy/M/d"
            
        }
        
        return NSAttributedString(
            string: formatter.string(from: mkmessages[indexPath.section].sentDate),
            attributes: [.font: UIFont.systemFont(ofSize: 12.0), .foregroundColor: UIColor.secondaryLabel])
    }
}



extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        print(" tap on image message")
    }
    
}


extension ChatViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
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
        
        if indexPath.section % 3 == 0 {
            
            if (indexPath.section == 0) && loadedMessageDictionaries.count > displayingMessagesCount {
                
                return 40
            }
            
            return 18
        }
        
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) {
        
//        avatarView.set(avatar: Avatar(initials: "R"))
//        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        avatarView.image = isFromCurrentSender(message: message) ? senderImage : recipientImage
    }
    
    // messageBottomLabelの高さ
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        if text != "" {
            typingIndicatorUpdate()
        }
    }
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text)
            }
        }
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
        self.messagesCollectionView.scrollToLastItem()
    }
}




