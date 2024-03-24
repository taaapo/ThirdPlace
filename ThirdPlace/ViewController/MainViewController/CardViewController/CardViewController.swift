//
//  CardViewController.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/10.
//

import UIKit
import Shuffle
import Firebase
import ProgressHUD

class CardViewController: UIViewController {
    
    //MARK: - Vars
    private let cardStack = SwipeCardStack()
    private var initialCardModes: [UserCardModel] = []
    private var secondCardModel: [UserCardModel] = []
    private var userObjects: [FUser] = []
    
    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false
    
    var numberOfCardsAdded = 0
    //下記のIntは自由に変更可能
    var initialLoadNumber = 5

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザーを作るときはcreateUsersを加えてdownloadInitialUsersをコメントアウト
//        createUsers()
        downloadInitialUsers()
    }
    
    //MARK: - IBActions
    
    @IBAction func goToChatButtonPressed(_ sender: UIButton) {
        cardStack.swipe(.right, animated: true)
    }
    
    @IBAction func goToNextButtonPressed(_ sender: UIButton) {
        cardStack.swipe(.left, animated: true)
    }
    
    //MARK: - Layout cards
    private func layoutCardStackView() {
        
        cardStack.delegate = self
        cardStack.dataSource = self
        
        view.addSubview(cardStack)
        
        //下記でCardStackの場所を設定
        cardStack.frame = CGRect(x: (view.frame.width - 350)/2, y: 150, width: 350, height: 500)
    }
    
    //MARK: - Downloads Users
    private func downloadInitialUsers() {
        
        ProgressHUD.animate()
        
        FirebaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: initialLoadNumber, lastDocumentSnapshot: lastDocumentSnapshot) { allUsers, snapshot in
            
            if allUsers.count == 0 {
                ProgressHUD.dismiss()
            }
            
            self.lastDocumentSnapshot = snapshot
            self.isInitialLoad = false
            self.initialCardModes = []
            
            self.userObjects = allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    let cardModel = UserCardModel(id: user.objectId, 
                                                  name: user.username,
                                                  personality: user.personality,
                                                  worry: user.worry,
                                                  image: user.avatar)
                    
                    self.initialCardModes.append(cardModel)
                    self.numberOfCardsAdded += 1
                    
                    if self.numberOfCardsAdded == allUsers.count {
                        print("reload")
                        
                        DispatchQueue.main.async {
                            ProgressHUD.dismiss()
                            self.layoutCardStackView()
                        }
                    }
                }
            }
            print("initial \(allUsers.count) received")
            self.downloadMoreUsersInBackground()
        }
    }
    
    private func downloadMoreUsersInBackground() {
        
        FirebaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: 1000, lastDocumentSnapshot: lastDocumentSnapshot) { allUsers, snapshot in
            
            self.lastDocumentSnapshot = snapshot
            self.secondCardModel = []
            
            self.userObjects += allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    let cardModel = UserCardModel(id: user.objectId, 
                                                  name: user.username,
                                                  personality: user.personality,
                                                  worry: user.worry,
                                                  image: user.avatar)
                    
                    self.secondCardModel.append(cardModel)
                }
            }
        }
    }
    
    //MARK: - Navigation
    private func showUserProfileFor(userId: String) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserProfileTableView") as! UserProfileTableViewController
        
        profileView.userObject = getUserWithId(userId: userId)
        profileView.delegate = self
        
        self.present(profileView, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    private func getUserWithId(userId: String) -> FUser? {
        
        for user in userObjects {
            if user.objectId == userId {
                return user
            }
        }
        
        return nil
    }
    
    private func goToChat(user: FUser) {
        
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: user)
        
        let chatView = ChatViewController(chatId: chatRoomId, recipientId: user.objectId, recipientName: user.username)
        
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
        
    }
}

extension CardViewController: SwipeCardStackDelegate, SwipeCardStackDataSource {
    
    //MARK: - DataSource
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = UserCard()
        card.footerHeight = 120
        card.swipeDirections = [.left, .right]
        
        for direction in card.swipeDirections {
            card.setOverlay(UserCardOverlay(direction: direction), forDirection: direction)
        }
        
        card.configure(withModel: showReserve ? secondCardModel[index] : initialCardModes[index])
        
        return card
    }
    
    func numberOfCards(in cardStack: Shuffle.SwipeCardStack) -> Int {
        return showReserve ? secondCardModel.count : initialCardModes.count
    }
    
    //MARK: - Delegate
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        
        print("finished with cards, show reserve is ", showReserve)
        
        initialCardModes = []
        
        if showReserve {
            secondCardModel = []
        }
        
        showReserve = true
        layoutCardStackView()
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        if direction == .right {
            let user = getUserWithId(userId: showReserve ? secondCardModel[index].id : initialCardModes[index].id)!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.goToChat(user: user)
            }
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        
        showUserProfileFor(userId: showReserve ? secondCardModel[index].id : initialCardModes[index].id)
    }
}

extension CardViewController: UserProfileTableViewControllerDelegate {
    
    func goToChat() {
        cardStack.swipe(.right, animated: true)
    }
    
    func goToNext() {
        cardStack.swipe(.left, animated: true)
    }
}
