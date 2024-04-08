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
    
    //MARK: - IBOutlets
    @IBOutlet weak var emptyDataView: EmptyDataView!
    
    //MARK: - Vars
    private let cardStack = SwipeCardStack()
    private var initialCardModels: [UserCardModel] = []
    private var secondCardModels: [UserCardModel] = []
    private var userObjects: [FUser] = []
    
    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false
    
    var numberOfCardsAdded = 0
    //下記のIntは自由に変更可能
    var initialLoadNumber = 20

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showEmptyDataView(loading: true)
        emptyDataView.delegate = self
        
        //ユーザーを作るときはcreateUsersを加えてdownloadInitialUsersをコメントアウト
//        createUsers()
        
        downloadInitialUsers()
    }
    
    private func showEmptyDataView(loading: Bool) {
        
        emptyDataView.isHidden = false
        emptyDataView.reloadButton.isEnabled = true
        
        //loadingとそうでない時でimageNamgeを変えたいときは、下記を加える
        //let imageName = loading ? "searchingBackground" : "seenAllBackground"
        let imageName = "検索マーク"
        let title = loading ? "ユーザーを探しています" : "すべてのユーザーをスワイプしました"
        let subTitle = loading ? "お待ちください" : "しばらく経ってから再度お試しください"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.view.bringSubviewToFront(self.emptyDataView)
        }
        
        emptyDataView.imageView.image = UIImage(named: imageName)
        emptyDataView.titleLabel.text = title
        emptyDataView.subTitleLabel.text = subTitle
        emptyDataView.reloadButton.isHidden = loading
    }
    
    private func hideEmptyDataView() {
        emptyDataView.isHidden = true
    }
    
    private func resetLoadCount() {
        isInitialLoad = true
        showReserve = false
        lastDocumentSnapshot = nil
        numberOfCardsAdded = 0
    }
    
    
    //MARK: - IBActions
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        cardStack.swipe(.right, animated: true)
    }
    
    @IBAction func goToNextButtonPressed(_ sender: UIButton) {
        cardStack.swipe(.left, animated: true)
    }
    
    //MARK: - Layout cards
    private func layoutCardStackView() {
        
        hideEmptyDataView()
        
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
            self.initialCardModels = []
            
            self.userObjects = allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    let cardModel = UserCardModel(id: user.objectId, 
                                                  name: user.username,
                                                  personality: user.personality,
                                                  worry: user.worry,
                                                  image: user.avatar)
                    
                    self.initialCardModels.append(cardModel)
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
            self.secondCardModels = []
            
            self.userObjects += allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    let cardModel = UserCardModel(id: user.objectId, 
                                                  name: user.username,
                                                  personality: user.personality,
                                                  worry: user.worry,
                                                  image: user.avatar)
                    
                    self.secondCardModels.append(cardModel)
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
        
        let chatView = ChatViewController(chatId: chatRoomId, recipientId: user.objectId, recipientName: user.username, senderImage: (FUser.currentUser()?.avatar)!, recipientImage: (user.avatar)!)
        
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
        
        card.configure(withModel: showReserve ? secondCardModels[index] : initialCardModels[index])
        
        return card
    }
    
    func numberOfCards(in cardStack: Shuffle.SwipeCardStack) -> Int {
        return showReserve ? secondCardModels.count : initialCardModels.count
    }
    
    //MARK: - Delegate
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        
        //print("finished with cards, show reserve is ", showReserve)
        
        initialCardModels = []
        
        if showReserve {
            secondCardModels = []
        }
        
        showReserve = true
        layoutCardStackView()
        
        
        if secondCardModels.isEmpty {
            showEmptyDataView(loading: false)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        if direction == .right {
            //let user = getUserWithId(userId: showReserve ? secondCardModel[index].id : initialCardModes[index].id)!
            let userId = showReserve ? secondCardModels[index].id : initialCardModels[index].id
            //print(userId, "is userId")
            saveLikeToUser(userId: userId)
            //カードを右スワイプした時にチャットに行きたい場合は下記をコメントアウト
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.goToChat(user: user)
//            }
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        
        showUserProfileFor(userId: showReserve ? secondCardModels[index].id : initialCardModels[index].id)
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

extension CardViewController: EmptyDataViewDelegate {
    
    func didClickReloadButton() {
        resetLoadCount()
        downloadInitialUsers()
        emptyDataView.reloadButton.isEnabled = false
    }
    
}
