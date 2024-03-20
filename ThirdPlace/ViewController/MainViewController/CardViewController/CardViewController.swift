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
        
        print("Swipe to", direction)
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        
        print("selected card at", index)
    }
    
}
